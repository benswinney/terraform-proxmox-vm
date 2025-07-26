# Contributing to Terraform Proxmox VM

Thank you for your interest in contributing to this project! This guide will help you get started with development and contributions.

## 🚀 Getting Started

### Prerequisites for Development

- **Terraform** >= 1.0
- **Git** for version control
- **Proxmox VE** test environment (recommended)
- **Text editor** or IDE with Terraform support

### Development Environment Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/terraform-proxmox-vm.git
   cd terraform-proxmox-vm
   ```

2. **Set up Test Environment**
   ```bash
   cp terraform.tfvars.example terraform.tfvars.dev
   # Configure with your test Proxmox environment
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

## 🏗️ Project Structure

```
.
├── main.tf                 # Core VM resource with for_each logic
├── variables.tf           # Variable definitions (multi-VM + legacy)
├── provider.tf           # Provider configuration
├── outputs.tf            # Multi-VM aware outputs
├── terraform.tfvars.example  # Configuration examples
├── CLAUDE.md             # AI assistant guidance
├── README.md             # User documentation
└── CONTRIBUTING.md       # This file
```

### Key Architecture Components

- **Configuration Merging**: `locals` block implements three-tier hierarchy
- **Multi-VM Support**: `for_each` pattern with `proxmox_vm_qemu` resource
- **Backward Compatibility**: Legacy single-VM variables still supported
- **Output Structure**: Both multi-VM and legacy outputs maintained

## 📝 Development Guidelines

### Code Style

1. **Terraform Formatting**
   ```bash
   terraform fmt -recursive
   ```

2. **Variable Naming**
   - Use descriptive names: `cpu_cores` not `cores`
   - Follow existing patterns: `ci_*` for cloud-init variables
   - Maintain consistency with legacy variables where applicable

3. **Documentation**
   - All variables must have clear descriptions
   - Include examples for complex configurations
   - Update README.md for user-facing changes

### Configuration Changes

#### Adding New VM Options

1. **Update Variable Definition**
   ```hcl
   # In variables.tf, add to both vms object and global_defaults object
   new_option = optional(string, "default-value")
   ```

2. **Update Configuration Merging**
   ```hcl
   # In main.tf locals block
   new_option = coalesce(vm_config.new_option, var.global_defaults.new_option, "fallback")
   ```

3. **Apply to Resource**
   ```hcl
   # In proxmox_vm_qemu resource
   new_parameter = each.value.new_option
   ```

4. **Update Examples**
   - Add to `terraform.tfvars.example`
   - Include in README.md if significant

#### Modifying Existing Options

- **Breaking Changes**: Require major version bump and clear migration guide
- **Non-Breaking Changes**: Maintain backward compatibility
- **Deprecations**: Mark clearly and provide migration path

### Testing

#### Manual Testing

1. **Syntax Validation**
   ```bash
   terraform validate
   terraform fmt -check
   ```

2. **Configuration Testing**
   ```bash
   # Test with minimal config
   terraform plan -var-file=terraform.tfvars.minimal
   
   # Test with complex multi-VM config
   terraform plan -var-file=terraform.tfvars.complex
   ```

3. **Legacy Compatibility**
   ```bash
   # Test legacy single-VM variables still work
   terraform plan -var="vm_name=test-vm" -var="target_node=node1"
   ```

#### Test Scenarios

- **Single VM**: Legacy variables only
- **Multi-VM**: Various VM configurations
- **Mixed Config**: Global defaults with VM overrides
- **Edge Cases**: Empty configurations, null values
- **Template Variations**: Different templates per VM
- **Multi-Node**: VMs across different Proxmox nodes

### Output Testing

Verify all outputs work correctly:

```bash
terraform apply
terraform output vms
terraform output vm_count
terraform output vm_ip_addresses
terraform output ssh_commands

# Legacy outputs
terraform output vm_id
terraform output vm_name
```

## 🐛 Bug Reports

### Before Reporting

- Check existing issues for duplicates
- Test with latest version
- Verify issue exists with minimal configuration

### Bug Report Template

```markdown
**Terraform Version**: 
**Provider Version**: 
**Proxmox Version**: 

**Configuration**:
```hcl
# Minimal configuration that reproduces the issue
```

**Expected Behavior**:
What should happen

**Actual Behavior**:
What actually happens

**Error Messages**:
```
Full error output
```

**Steps to Reproduce**:
1. 
2. 
3. 
```

## ✨ Feature Requests

### Feature Request Guidelines

- Explain the use case and problem being solved
- Provide examples of desired configuration
- Consider backward compatibility impact
- Suggest implementation approach if possible

### Implementation Process

1. **Discuss**: Open issue for discussion before implementation
2. **Design**: Consider impact on existing users
3. **Implement**: Follow development guidelines
4. **Test**: Comprehensive testing including edge cases
5. **Document**: Update README and examples

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code formatted with `terraform fmt`
- [ ] Configuration validates with `terraform validate`
- [ ] All outputs tested and working
- [ ] Documentation updated (README, examples)
- [ ] Backward compatibility maintained
- [ ] Legacy functionality still works

### PR Description Template

```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix or feature requiring user action)
- [ ] Documentation update

## Testing
- [ ] Terraform validate passes
- [ ] Configuration tested with Proxmox
- [ ] Legacy compatibility verified
- [ ] All outputs working

## Configuration Examples
```hcl
# Example of new/changed configuration
```

## Documentation
- [ ] README.md updated
- [ ] terraform.tfvars.example updated
- [ ] CLAUDE.md updated if needed
```

### Review Process

1. **Automated Checks**: Terraform formatting and validation
2. **Code Review**: Maintainer review for quality and compatibility
3. **Testing**: Functional testing in test environment
4. **Documentation**: Verify all documentation is updated
5. **Merge**: Squash merge preferred for clean history

## 🚨 Breaking Changes

### Guidelines for Breaking Changes

- Major version bump required (1.x.x → 2.0.0)
- Clear migration guide provided
- Deprecation warnings in previous version when possible
- Maintain legacy compatibility for at least one major version

### Migration Guide Requirements

- Step-by-step migration instructions
- Before/after configuration examples
- Common pitfalls and solutions
- Validation steps to confirm successful migration

## 📊 Release Process

### Version Numbering

- **Major** (X.0.0): Breaking changes
- **Minor** (x.Y.0): New features, backward compatible
- **Patch** (x.y.Z): Bug fixes, backward compatible

### Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version tagged in git
- [ ] Release notes published

## 💬 Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Focus on the problem, not the person

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community discussion
- **Pull Requests**: Code contributions and reviews

## 🏷️ Labels and Categories

### Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or improvement
- `documentation`: Documentation updates
- `question`: General questions
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed

### Priority Labels

- `critical`: Production-breaking issues
- `high`: Important features/fixes
- `medium`: General improvements
- `low`: Nice-to-have features

---

**Questions?** Feel free to open a discussion or reach out to the maintainers!