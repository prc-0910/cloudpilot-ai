# Azure VMware Migration Landing Zone

This Terraform project deploys a production-oriented Azure foundation for migrating approximately 50 VMware virtual machines to Azure with disaster recovery, security, monitoring, and cost controls.

## Architecture

The project implements:

- Enterprise-style resource group separation for network, management, security, recovery, and DR workloads.
- Hub and spoke networking with VNet peering.
- Azure DDoS Network Protection on hub and spoke VNets.
- Azure Firewall Premium with DNS proxy, threat intelligence deny mode, baseline platform allow rules, and spoke default routing.
- Azure Bastion Standard for managed administrative access.
- Network Security Groups on workload subnets.
- Log Analytics Workspace, diagnostic settings, action group, and a firewall health alert.
- Recovery Services Vault with geo-redundant storage, soft delete, immutability, and VM backup policy.
- Azure Site Recovery fabric, protection container, replication policy, and network mapping scaffolding.
- Azure Key Vault Premium with purge protection, RBAC authorization, diagnostics, and optional private endpoint.
- Private DNS zone and private endpoint integration for Key Vault.

## Module Summary

### `modules/resource-group`

Creates the enterprise resource group layout:

- `rg-<prefix>-network`
- `rg-<prefix>-management`
- `rg-<prefix>-security`
- `rg-<prefix>-recovery`
- `rg-<prefix>-dr`

This keeps ownership, policy, budgets, and role assignment boundaries clean.

### `modules/network`

Creates the hub and spoke topology:

- Hub VNet and configurable hub subnets.
- Spoke VNets and configurable spoke subnets.
- Azure Bastion Standard with a zone-redundant public IP.
- DDoS Protection Plan attached to all VNets.
- Workload subnet NSGs.
- Spoke route tables and hub/spoke VNet peering.

The module intentionally creates route tables without default routes; the firewall module adds the next-hop route after the firewall private IP exists.

### `modules/firewall`

Creates Azure Firewall Premium:

- Zone-redundant public IP.
- Firewall Policy Premium.
- DNS proxy and IDPS alert mode.
- Baseline Microsoft platform egress rules.
- Default `0.0.0.0/0` routes from spoke route tables to the firewall private IP.

Tune the policy rule collections for application-specific traffic before production rollout.

### `modules/monitoring`

Creates centralized observability:

- Log Analytics Workspace.
- Action Group for operations notifications.
- Diagnostic settings for supplied platform resources.
- Azure Firewall health metric alert.

Update `action_group_email_address` in `main.tf` or expose it as a root variable for your organization.

### `modules/backup`

Creates backup foundation:

- Recovery Services Vault.
- Geo-redundant vault storage.
- Soft delete.
- Unlocked immutability.
- Daily Azure VM backup policy with daily and weekly retention.
- Vault diagnostics to Log Analytics.

VM protection should be attached after migrated VMs exist, either by adding `azurerm_backup_protected_vm` resources or by onboarding through Azure Policy.

### `modules/recovery`

Creates Azure Site Recovery scaffolding:

- Primary and secondary ASR fabrics.
- Primary and secondary protection containers.
- Replication policy.
- Protection container mapping.
- Network mapping from migration spoke to DR spoke.

For VMware-to-Azure replication, the ASR appliance/process server registration, vCenter discovery, mobility service installation, and per-VM replication enablement are operational steps that depend on discovered VMware inventory. Keep those in the migration runbook or generate per-VM Terraform once the discovered inventory and target sizing are finalized.

### `modules/security`

Creates security services:

- Azure Key Vault Premium.
- RBAC authorization.
- Purge protection and 90-day soft delete.
- Optional private endpoint.
- Private DNS zone for Key Vault.
- Diagnostics to Log Analytics.

## Usage

1. Authenticate to Azure:

   ```powershell
   az login
   az account set --subscription "<subscription-id>"
   ```

2. Create a working variables file:

   ```powershell
   Copy-Item terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` for your enterprise address plan, tags, regions, admin CIDRs, and retention requirements.

4. Initialize and deploy:

   ```powershell
   terraform init
   terraform fmt -recursive
   terraform validate
   terraform plan -out tfplan
   terraform apply tfplan
   ```

## Production Notes

- Use a remote backend such as Azure Storage with blob versioning, container soft delete, private endpoint access, and state locking before team use.
- Apply Azure Policy initiatives for allowed regions, required tags, diagnostic settings, private endpoint requirements, and deny public IPs except approved services.
- Replace the sample operations email address before deploying.
- Review Azure Firewall application and network rules for Windows activation, Azure Arc, Azure Migrate, ASR, backup, monitoring agents, package repositories, and workload-specific destinations.
- Place migrated VMs in availability zones or availability sets according to application dependency and region capability.
- Use reservations or Azure Savings Plan after right-sizing migrated workloads.
- Enable Defender for Cloud plans according to workload criticality.
- Integrate Key Vault with customer-managed keys if your compliance baseline requires CMK encryption.
- Keep ASR test failovers scheduled and documented. Test failover does not replace application-level DR validation.

## Cost Optimization

- Azure Firewall Premium and DDoS Network Protection are significant shared costs; use the hub model to amortize them across spokes.
- Right-size the 50 migrated VMs with Azure Migrate assessment data before final replication.
- Use Log Analytics daily caps and retention appropriate to compliance requirements.
- Apply VM schedules to non-production migrated workloads.
- Review backup retention and vault redundancy by workload tier.

## Expected Customization Before Production

- Replace placeholder action group email.
- Add remote state backend.
- Add subscription-level management groups and Azure Policy assignments if this code is deployed as part of a full enterprise-scale landing zone program.
- Add per-VM modules or generated HCL after Azure Migrate assessment confirms target SKUs, disks, zones, backup tiers, and ASR replication settings.
