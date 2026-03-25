# Security Policy

## Overview

This is a **demonstration and portfolio project** showcasing Azure infrastructure patterns for DLT workloads. It is designed to be safely used in public repositories.

## Disclaimers

- **Demo Project**: This is a portfolio piece to showcase patterns
- **No Warranty**: Use at your own risk (see LICENSE)
- **Best Effort Support**: Maintained by volunteers
- **Public Repository**: All code is designed for safe public disclosure

## Reporting a Vulnerability

### How to Report

If you discover a security vulnerability, please report it via:

1. **Preferred**: [GitHub Security Advisories](https://github.com/mikestankavich/hashsphere-azure-foundation/security/advisories/new)
2. **Alternative**: Open a private issue describing the vulnerability

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if known)

### Response Timeline

**Best effort** - This is a volunteer-maintained demo project:
- We'll acknowledge receipt when we can
- Fixes will be prioritized based on severity
- No guaranteed timeline for patches

### Safe Harbor

We support responsible disclosure and will not take legal action against security researchers who:
- Report vulnerabilities in good faith
- Avoid privacy violations and service disruption
- Give us reasonable time to address issues before public disclosure

## Scope

### In Scope
- Vulnerabilities in Terraform code
- Exposed secrets or credentials in code/config
- Container image security issues
- Documentation errors that could lead to insecure deployments

### Out of Scope
- Issues in simulated node behavior (intentionally simplified)
- Azure platform security (report to Microsoft directly)
- Hedera/Hashgraph platform security (report to Hashgraph directly)

## Security Best Practices for Users

When using this module:
- **Never commit real Azure credentials** - Use environment variables
- **Review all Terraform code** before deploying
- **Use separate Azure subscription** for testing
- **Rotate credentials** if accidentally exposed

## Security Hall of Fame

We recognize security researchers who responsibly disclose vulnerabilities:

_No entries yet. Be the first to responsibly disclose a security issue!_

---

**Last Updated**: 2026-03-25

**Remember**: This is educational infrastructure. Always review and understand code before using.
