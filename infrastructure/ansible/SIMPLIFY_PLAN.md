# Ansible Simplification Plan

## Current Issues
1. **Nested inventory structure** - inventory/production/hosts.yml is unnecessarily deep
2. **Duplicate host_vars** - Both inventory/host_vars and inventory/production/host_vars
3. **Complex playbook nesting** - playbooks/service/action.yml pattern is verbose
4. **Empty role directories** - defaults, files, handlers, meta, templates mostly unused
5. **Vault not used** - vault.yml exists but not referenced

## Proposed Structure

```
ansible/
├── ansible.cfg
├── inventory.yml           # Single inventory file (was: inventory/production/hosts.yml)
├── group_vars/            # Group variables
│   └── all.yml
├── playbooks/             # Flat structure
│   ├── k3s-deploy.yml
│   ├── k3s-upgrade.yml
│   └── bind9-deploy.yml
└── roles/                 # Keep only needed directories
    ├── k3s_server/
    │   └── tasks/
    │       └── main.yml
    ├── k3s_agent/
    │   └── tasks/
    │       └── main.yml
    └── bind9/
        └── tasks/
            └── main.yml
```

## Benefits
- Single inventory file (easier to understand)
- Flat playbook structure (easy to find)
- Minimal role structure (only tasks, no unused dirs)
- Consistent with simplified Terraform approach
- Easy to reason about and maintain

## Implementation
1. Flatten inventory structure
2. Consolidate playbooks
3. Remove empty role directories
4. Update ansible.cfg
5. Test and validate
