package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var config struct {
	role     string
	httpPort string
	nodeID   string
}

// HealthState caches node status for the /healthz endpoint
type HealthState struct {
	mu        sync.RWMutex
	healthy   bool
	round     uint64
	peers     int
	lastCheck time.Time
}

func (h *HealthState) Update(healthy bool, round uint64, peers int) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.healthy = healthy
	h.round = round
	h.peers = peers
	h.lastCheck = time.Now()
}

func (h *HealthState) Get() (bool, uint64, int, time.Time) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return h.healthy, h.round, h.peers, h.lastCheck
}

var healthState = &HealthState{healthy: true}

var startTime = time.Now()

// Prometheus metrics — names modeled on hgraph.com Hedera Stats
var (
	consensusTime = prometheus.NewHistogram(prometheus.HistogramOpts{
		Name:    "hashsphere_consensus_time_seconds",
		Help:    "Time to consensus per round",
		Buckets: []float64{1, 2, 3, 4, 5, 7, 10},
	})
	transactionsPerSecond = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "hashsphere_transactions_per_second",
		Help: "Current transactions per second",
	})
	transactionsTotal = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name: "hashsphere_transactions_total",
		Help: "Total transactions by service type",
	}, []string{"service"})
	activeAccounts = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "hashsphere_active_accounts",
		Help: "Currently active accounts",
	})
	peerCount = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "hashsphere_peer_count",
		Help: "Number of connected peers",
	})
	nodeStatus = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "hashsphere_node_status",
		Help: "Node health status (1=healthy, 0=unhealthy)",
	})
	roundNumber = prometheus.NewCounter(prometheus.CounterOpts{
		Name: "hashsphere_round_number",
		Help: "Current consensus round number",
	})
)

func init() {
	prometheus.MustRegister(
		consensusTime,
		transactionsPerSecond,
		transactionsTotal,
		activeAccounts,
		peerCount,
		nodeStatus,
		roundNumber,
	)
}

func main() {
	config.role = getEnv("HSPHERE_NODE_ROLE", "consensus")
	config.httpPort = getEnv("HSPHERE_HTTP_PORT", "8080")
	config.nodeID = getEnv("HSPHERE_NODE_ID", config.role+"-0")

	http.HandleFunc("/", getRoot)
	http.HandleFunc("/healthz", getHealth)
	http.Handle("/metrics", promhttp.Handler())

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	go simulateMetrics(ctx)

	go func() {
		addr := ":" + config.httpPort
		logInfo("Starting %s node %s on %s", config.role, config.nodeID, addr)
		if err := http.ListenAndServe(addr, nil); err != nil && !errors.Is(err, http.ErrServerClosed) {
			fmt.Fprintf(os.Stderr, "FATAL: %v\n", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	logInfo("Shutting down...")
}

func simulateMetrics(ctx context.Context) {
	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()

	var round uint64
	peers := 3 + rand.Intn(3) // 3-5 peers
	accounts := 1000.0

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			round++

			// Simulate consensus time: 3-5 seconds with jitter
			ct := 3.0 + rand.Float64()*2.0
			// Every ~20 rounds, simulate a brief degraded period
			degraded := round%20 == 0
			if degraded {
				ct = 7.0 + rand.Float64()*3.0
			}
			consensusTime.Observe(ct)

			// TPS: 100-500 normal, drops during degraded
			tps := 200.0 + rand.Float64()*300.0
			if degraded {
				tps = 30.0 + rand.Float64()*70.0
			}
			transactionsPerSecond.Set(tps)

			// Increment transaction counters by service type
			transactionsTotal.WithLabelValues("crypto").Add(tps * 0.4 * 3) // 40% crypto
			transactionsTotal.WithLabelValues("hcs").Add(tps * 0.2 * 3)    // 20% HCS
			transactionsTotal.WithLabelValues("hts").Add(tps * 0.3 * 3)    // 30% HTS
			transactionsTotal.WithLabelValues("hscs").Add(tps * 0.1 * 3)   // 10% smart contracts

			// Active accounts: slow growth with jitter
			accounts += rand.Float64() * 5
			activeAccounts.Set(math.Round(accounts))

			// Peer count: stable with rare changes
			if rand.Intn(50) == 0 {
				peers = 3 + rand.Intn(3)
			}
			peerCount.Set(float64(peers))

			// Node status
			healthy := !degraded
			if healthy {
				nodeStatus.Set(1)
			} else {
				nodeStatus.Set(0)
			}

			roundNumber.Add(1)
			healthState.Update(healthy, round, peers)

			logInfo("[%s] round=%d tps=%.0f consensus=%.2fs peers=%d healthy=%v",
				config.role, round, tps, ct, peers, healthy)
		}
	}
}

func getRoot(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{
		"service":   "hashsphere-node-simulator",
		"role":      config.role,
		"node_id":   config.nodeID,
		"uptime":    time.Since(startTime).String(),
		"endpoints": []string{"/healthz", "/metrics"},
	})
}

func getHealth(w http.ResponseWriter, _ *http.Request) {
	healthy, round, peers, ts := healthState.Get()

	status := http.StatusOK
	if !healthy {
		status = http.StatusServiceUnavailable
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]any{
		"healthy":    healthy,
		"role":       config.role,
		"node_id":    config.nodeID,
		"round":      round,
		"peers":      peers,
		"last_check": ts.Format(time.RFC3339),
	})
}

func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok {
		return v
	}
	return fallback
}

func logf(level, format string, args ...any) {
	ts := time.Now().Format("01-02|15:04:05.000")
	msg := fmt.Sprintf(format, args...)
	fmt.Printf("[%s] [%s] %s\n", level, ts, msg)
}

func logInfo(format string, args ...any) { logf("INFO", format, args...) }
