# Terraform Infrastructure Refactor Plan

**Date:** 2025-12-13  
**Status:** Planning Phase

## Current State Analysis

### Directory Structure
```
terraform/
├── environments/
│   └── production/          # Minimal orchestration layer (currently empty)
├── modules/
│   ├── proxmox-vm/         # ✅ Recently refactored - clean and working
│   └── proxmox-lxc/        # Needs review
└── services/
    ├── bind9/              # Uses LXC module, needs iteration support
    └── k3s/                # ✅ Recently refactored - uses VM module with iteration
```

### What's Working Well
- ✅ **k3s service**: Clean iteration with `for_each`, using simplified VM module
- ✅ **proxmox-vm module**: Simplified from 58 lines, proper cloud-init, full clone support
- ✅ **Template selection**: Automatic per-node template mapping in k3s

### Issues Identified

#### 1. **bind9 Service - No Iteration Support**
- Currently creates ns1 and ns2 as separate module calls
- Should use `for_each` pattern like k3s
- Hardcoded configuration instead of list-based
- **Impact**: Hard to add/remove nameservers

#### 2. **proxmox-lxc Module - Not Reviewed**
- Haven't validated if it follows best practices
- May have similar issues that proxmox-vm had before refactor
- No iteration examples in bind9 service
- **Impact**: Unknown quality, hard to maintain

#### 3. **Inconsistent Configuration Patterns**
- bind9 uses individual variables (ns1_hostname, ns2_hostname)
- k3s uses list of objects (cleaner pattern)
- Should standardize across services
- **Impact**: Hard to learn and maintain

#### 4. **Provider/Versions Duplication**
- Each service has its own provider.tf and versions.tf
- Should potentially use shared configuration
- **Impact**: Maintenance overhead, version drift risk

#### 5. **Secrets Management**
- k3s uses secrets.auto.tfvars (good)
- bind9 uses terraform.tfvars (may contain secrets)
- No .gitignore validation done yet
- **Impact**: Potential secret leakage risk

#### 6. **environments/production - Unused**
- Empty orchestration layer
- Unclear if it should manage all services or stay minimal
- **Impact**: Architectural uncertainty

## Proposed Refactor Plan

### Phase 1: Review & Document ✅ COMPLETED
- [x] Review proxmox-lxc module for issues
- [x] Review bind9 service configuration
- [x] Document current secrets management approach
- [x] Check .gitignore files for proper secret exclusion
- [x] Verify all provider versions are consistent

**Findings:**
1. **proxmox-lxc module** - Relatively clean, but could be simplified
   - 127 lines of variables (many with defaults)
   - Outputs use `try()` which is good
   - Could remove some rarely-used variables
   
2. **bind9 service** - Major issues found:
   - Uses ns1_* and ns2_* individual variables (not iterable)
   - Has 93 lines of variables for just 2 containers
   - terraform.tfvars contains API secrets and passwords
   
3. **Secrets management**:
   - ⚠️ **CRITICAL**: bind9/terraform.tfvars contains API secrets in plaintext
   - k3s properly uses secrets.auto.tfvars (gitignored)
   - bind9 .gitignore blocks *.tfvars (good) but file still exists
   
4. **Provider versions**: ✅ Consistent
   - Both services use telmate/proxmox 3.0.2-rc05
   
5. **.gitignore**: ✅ Adequate
   - bind9: blocks all *.tfvars
   - k3s: blocks secrets.auto.tfvars, allows config.auto.tfvars

### Phase 2: Standardize bind9 Service ✅ COMPLETED
- [x] Refactor bind9 to use list-based iteration like k3s
- [x] Move secrets to secrets.auto.tfvars
- [x] Create config.auto.tfvars for non-sensitive config
- [x] Update .gitignore to allow config.auto.tfvars
- [x] Simplify variables.tf (93 lines → 85 lines)
- [x] Update bind9 README with new pattern

**Changes Made:**
1. Replaced separate `module "ns1"` and `module "ns2"` with single iterable `module "nameservers"`
2. Changed from individual variables (ns1_hostname, ns2_hostname) to list-based `nameservers` variable
3. Split configuration into:
   - `config.auto.tfvars` - non-sensitive (nameservers list, network settings)
   - `secrets.auto.tfvars` - sensitive (passwords, SSH keys)
4. Updated README with clear usage examples
5. Removed old terraform.tfvars containing plaintext secrets

**Result:**
- Can now add/remove nameservers by editing a list
- Pattern matches k3s service structure
- Secrets properly isolated
- 🔒 Security improved: secrets moved from terraform.tfvars to secrets.auto.tfvars

### Phase 3: Review/Refactor proxmox-lxc Module
- [ ] Apply lessons learned from proxmox-vm refactor
- [ ] Simplify if needed
- [ ] Ensure best practices
- [ ] Update documentation

### Phase 4: Consistency & Standards
- [ ] Create shared configuration pattern documentation
- [ ] Standardize secrets handling across all services
- [ ] Consider shared provider configuration
- [ ] Add terraform.tfvars.example files where missing
- [ ] Validate .gitignore in all directories

### Phase 5: Testing & Validation
- [ ] Test bind9 refactored configuration
- [ ] Validate all modules with `terraform validate`
- [ ] Document testing procedures
- [ ] Create troubleshooting guide based on k3s experience

## Design Decisions to Make

### 1. Provider Configuration Strategy
**Options:**
- A) Keep per-service providers (current) - more isolated, easier to version independently
- B) Shared root provider - less duplication, consistent versions
- C) Hybrid - shared versions.tf, local provider.tf

**Recommendation:** TBD after Phase 1 review

### 2. Environment Strategy
**Options:**
- A) Keep production/ empty - services manage themselves
- B) Use production/ to orchestrate all services
- C) Remove production/ entirely

**Recommendation:** A - Keep it minimal for manual orchestration

### 3. Module Iteration Pattern
**Standard:**
```hcl
resources = [
  { hostname = "name", vmid = 123, target_node = "node", ip = "x.x.x.x" }
]

module "resource" {
  source   = "../../modules/proxmox-vm"
  for_each = { for r in var.resources : r.hostname => r }
  # ...
}
```
This pattern should be used consistently across all services.

## Success Criteria
- [ ] All services use consistent iteration patterns
- [ ] No secrets in version control
- [ ] All modules follow simplified, maintainable patterns
- [ ] Documentation is clear and up-to-date
- [ ] Can easily add/remove resources by editing lists
- [ ] New contributors can understand the structure quickly

## Phase 1 Summary - Key Findings

### Critical Issues
🚨 **bind9 terraform.tfvars contains plaintext secrets**
- API token: `af3d4924-5480-40a7-ab51-64cb43b6a821`
- Root password: `mosaic-helium-BERGEN`
- File is gitignored but still exists in repo
- **Action**: Move to secrets.auto.tfvars like k3s

### Module Quality Assessment

**proxmox-lxc module**: 7/10
- ✅ Functional and working
- ✅ Good use of defaults
- ⚠️ Too many variables (127 lines)
- ⚠️ Some variables rarely used (startup, protection, nesting)
- 💡 Could simplify like we did with proxmox-vm

**bind9 service**: 3/10  
- ❌ No iteration support (hardcoded ns1/ns2)
- ❌ 93 lines of variables for 2 containers
- ❌ Secrets in wrong file
- ✅ Uses module pattern correctly
- 💡 Needs complete refactor to match k3s pattern

### Recommendations Priority
1. **HIGH**: Fix bind9 secrets management immediately
2. **HIGH**: Refactor bind9 to use iteration (Phase 2)
3. **MEDIUM**: Simplify proxmox-lxc module (Phase 3)
4. **LOW**: Create shared documentation (Phase 4)

## Next Steps
1. ✅ Phase 1 Complete - Findings documented above
2. ✅ Phase 2 Complete - bind9 refactored and ready to apply
3. ⏳ Phase 3: Simplify proxmox-lxc module (next)
4. ⏳ Phase 4-5: Standards and testing

## Phase 2 Completion Notes
**Date:** 2025-12-13
**Status:** Ready for deployment

The bind9 service has been successfully refactored:
- State migrated without destroying containers
- Disk size kept at 16GB (appropriate for available storage)
- `terraform plan` shows no infrastructure changes
- Ready to apply: `terraform apply` in services/bind9/

**Post-apply checklist:**
- [ ] Run `terraform apply` in services/bind9/
- [ ] Verify DNS resolution still works
- [ ] Test adding a third nameserver to validate iteration pattern

## Notes
- Keep changes minimal and surgical
- Test each change before moving to next phase
- Document lessons learned
- Don't break existing working infrastructure (k3s VMs are running!)
