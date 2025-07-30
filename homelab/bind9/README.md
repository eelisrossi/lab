# Automated Bind9 DNS-server setup

Terraform installs two Almalinux LXCs, and runs an Ansible playbook. The playbook updates the containers and installs OpenSSH-server, since it is missing from the Almalinux LXC image.

After the hosts are up, running the playbook 'setup-bind9' will set everything up for both of the servers to become functional DNS servers.

## Secrets

There are two secret files omitted from the public repository:

### credentials.auto.tfvars

This is for Terraform to use, and should reside in terraform directory.

```jinja
proxmox_api_url = "https://YOUR_PROXMOX_HOST_URL/api2/json"
proxmox_api_token_id = "YOUR_PROXMOX_API_TOKEN_ID"
proxmox_api_token_secret = "YOUR_PROXMOX_API_TOKEN_SECRET"

ct_root_password = "YOUR_CONTAINER_ROOT_PASSWORD"
ct_ssh_keys = <<-EOT
ssh-ed25519 YOUR_SSH_KEY1
ssh-ed25519 YOUR_SSH_KEY2
EOT
```

### vault.yml

This is for Ansible to use, and should reside in the ansible directory.
To create it, run `ansible-vault create vault.yml`.

For my setup, I have a secrets directory that is not in the repo. The password for the vault is saved there.

This is mainly for learning purposes, but also for obfuscating my homelab network a tiny bit.
Of course no-one should be able to get in since I don't expose any ports to the outside from my firewall.
```yaml

dns_records:
    hostname: ip
    # you can add as many hostname - ip pairs here as you need

dns_reverse_zones:
    # Your subnets IP in reverse, without the final octet
  - name: "XXX.XXX.XXX.in-addr.arpa"
    file: "XXX.XXX.XXX.rev"
    ptr_records:
      - ip_suffix: "10"
        hostname: "ns1"
      - ip_suffix: "11"
        hostname: "ns2"
    # same as with dns_records, you can add as many as needed
```
