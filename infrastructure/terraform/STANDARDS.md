# Terraform Standards and Best Practices

**Last Updated:** 2025-12-13  
**Status:** Active

## Module Structure

### Standard Module Pattern

All modules should follow this structure:
```
module-name/
├── main.tf         # Resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── versions.tf     # Provider version constraints
└── README.md       # Usage documentation
```

### Module Guidelines

1. **Keep it simple** - Remove rarely-used variables, use sensible defaults
2. **Use descriptions** - All variables must have description fields
3. **Sensitive data** - Mark passwords/keys as `sensitive = true`
4. **Defaults** - Provide defaults for optional parameters
5. **Documentation** - README with working example

## Service Structure

### Standard Service Pattern

```
service-name/
├── main.tf              # Module calls with iteration
├── variables.tf         # Service-level variables
├── outputs.tf           # Service outputs
├── versions.tf          # Provider versions
├── provider.tf          # Provider configuration
├── config.auto.tfvars   # Non-sensitive config (can commit)
├── secrets.auto.tfvars  # Sensitive data (gitignored)
├── .gitignore           # Secrets protection
└── README.md            # Usage guide
```

### Service Guidelines

1. **Use iteration** - Prefer `for_each` over multiple module calls
2. **List-based config** - Define resources as lists of objects:
   ```hcl
   resources = [
     { hostname = "name", vmid = 123, target_node = "node", ip = "x.x.x.x" }
   ]
   ```
3. **Split secrets** - config.auto.tfvars for settings, secrets.auto.tfvars for credentials
4. **Consistent naming** - Use descriptive, consistent variable names

## Configuration Management

### File Organization

**config.auto.tfvars** (can be committed):
- Resource definitions (lists of VMs/containers)
- Network settings
- Non-sensitive parameters

**secrets.auto.tfvars** (gitignored):
- Passwords
- SSH keys
- API tokens

### .gitignore Pattern

```gitignore
# Ignore secrets
secrets.auto.tfvars
*.tfvars
*.tfvars.*

# Allow config
!*.tfvars.example
!config.auto.tfvars
```

## Naming Conventions

### Resources
- **VMs**: `hostname-purpose` (e.g., `hlvm-k3s-w1`)
- **Containers**: `hlct-purpose` (e.g., `hlct-ns1`)
- Prefix: `hlvm-` for VMs, `hlct-` for LXC containers

### Variables
- Use clear, descriptive names
- Group related variables together
- Add descriptions to all variables

### Tags
- Use semicolon-separated format: `"tag1;tag2;tag3"`
- Include: OS type, purpose, management method
- Example: `"almalinux;k3s;worker;iac"`

## Iteration Pattern

### Standard for_each Pattern

```hcl
module "resources" {
  source   = "../../modules/module-name"
  for_each = { for r in var.resources : r.hostname => r }

  hostname    = each.value.hostname
  vmid        = each.value.vmid
  target_node = each.value.target_node
  # ... other parameters
}
```

### Benefits
- Easy to add/remove resources (edit a list)
- Consistent resource creation
- Scalable for many resources

## Provider Versions

### Current Standard
- **Provider**: `telmate/proxmox`
- **Version**: `3.0.2-rc05`
- **Terraform**: `>= 1.4.0`

All services must use the same provider version for consistency.

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use sensitive flag** for password/key variables
3. **gitignore secrets files** in all service directories
4. **Separate config from secrets** using auto.tfvars pattern
5. **Review diffs** before committing to ensure no secrets leaked

## Module Best Practices

### proxmox-vm Module
- Use cloud-init templates
- Set `ciuser` for SSH access
- Enable serial console for debugging
- Use full_clone for production
- Specify CPU type for compatibility

### proxmox-lxc Module
- Use unprivileged containers by default
- Enable nesting for Docker support
- Provide adequate disk space (16G typical)
- Use protection to prevent accidents

## Code Style

### Formatting
- Run `terraform fmt` before committing
- Use consistent indentation (2 spaces)
- Group related parameters together
- Add blank lines between sections

### Comments
- Minimal comments in code (self-documenting names preferred)
- Comments for complex logic only
- README for usage documentation

## Testing Workflow

Before applying changes:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Run `terraform plan` to preview changes
4. Review plan output carefully
5. Use `-target` for risky changes to test one resource first
6. Apply changes with `terraform apply`

## State Management

- State files are local (for now)
- Backup state before major changes
- Use `terraform state mv` for refactoring without recreation
- Never manually edit state files

## Examples

See individual service READMEs for working examples:
- `services/k3s/README.md` - VM iteration pattern
- `services/bind9/README.md` - LXC iteration pattern
- `modules/proxmox-vm/README.md` - VM module usage
- `modules/proxmox-lxc/README.md` - LXC module usage
