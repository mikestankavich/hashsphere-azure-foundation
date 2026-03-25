# Contributing to HashSphere Azure Foundation

Thank you for your interest in contributing! This project demonstrates Azure infrastructure patterns for DLT workloads, and we welcome improvements and feedback.

## Ways to Contribute

### 1. Report Issues
- Found a bug? [Open an issue](https://github.com/mikestankavich/hashsphere-azure-foundation/issues)
- Have a feature request? Describe your use case
- Documentation unclear? Let us know what's confusing

### 2. Submit Pull Requests
- Fix bugs or typos
- Add new module features
- Improve documentation
- Enhance error handling

## Development Setup

### Prerequisites
- Git
- Terraform >= 1.5
- Azure CLI
- Docker
- Go 1.24+
- just

### Testing Your Changes

1. **Clone and test**
   ```bash
   git clone https://github.com/mikestankavich/hashsphere-azure-foundation
   cd hashsphere-azure-foundation
   ```

2. **Validate infrastructure code**
   ```bash
   just validate
   just fmt
   just plan
   ```

3. **Test with your Azure subscription**
   - Use your own Azure credentials
   - Review all changes before applying
   - Clean up resources after testing

## Contribution Guidelines

### Code Style
- **Terraform code**: Follow [HashiCorp Style Guide](https://developer.hashicorp.com/terraform/language/style)
- **Markdown**: Use consistent formatting, clear headings

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat: add heartbeat monitor support
fix: correct status page section ordering
docs: clarify API token setup
chore: update provider version
```

### Pull Request Process

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Keep changes focused and atomic
   - Update documentation as needed
   - Add examples if introducing new features

4. **Test thoroughly**
   - Run `just validate` and `just plan`
   - Verify documentation changes render correctly
   - Check for exposed secrets or credentials

5. **Submit PR**
   - Provide clear description of changes
   - Link to related issues
   - Explain the "why" behind your changes

6. **Respond to feedback**
   - Address review comments
   - Be open to suggestions

## Security Considerations

When contributing:
- **Never commit real Azure credentials** - Use environment variables
- **Use example files only** (.env.local.example)
- **Review all infrastructure changes** before submitting
- **Report security issues** via [GitHub Security Advisories](https://github.com/mikestankavich/hashsphere-azure-foundation/security/advisories/new)

## Questions?

- Open a discussion in [GitHub Issues](https://github.com/mikestankavich/hashsphere-azure-foundation/issues)
- Check existing issues for similar questions
- Be patient - this is a demo/portfolio project

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community guidelines.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping improve this project!
