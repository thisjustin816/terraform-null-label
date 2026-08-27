# Migrating to v2

## Overview

Version 2 separates logical resource-code labels from provider-valid physical names. The base `id`, tag, descriptor, label, and normalized-context behavior stays compatible with v1. Resource-code keys, resource-rule schemas, physical-name membership, hashes, and several built-in rules change.

Keep existing infrastructure on its current v1 tag until you have compared every consumed name and reviewed a Terraform plan.

## Supported Terraform versions

Version 2 requires Terraform `>= 1.3.2, < 2.0.0`. Terraform 1.3.0 and 1.3.1 can fail inside Terraform Core after a successful child-module output precondition. The first 1.3 patch with the fix is 1.3.2. See [HashiCorp issue 31846](https://github.com/hashicorp/terraform/issues/31846), [pull request 31890](https://github.com/hashicorp/terraform/pull/31890), and the [Terraform 1.3.2 release](https://github.com/hashicorp/terraform/releases/tag/v1.3.2).

## Pre-upgrade checklist

- Record the exact v1 module tag and current physical names.
- Inventory every consumer of a resource-aware output.
- Identify resources whose names force replacement.
- Add each consumed v2 physical key to `required_resource_names`.
- Decide which names can change and which must stay explicit.
- Test one provider and environment at a time.
- Keep a reviewed rollback source pin.

## Breaking changes

### Terraform compatibility

The supported range is `>= 1.3.2, < 2.0.0`. Upgrade Terraform before changing the module source.

### Azure key namespace

Azure resource-code keys gain the `azure_` prefix unless they already have it. All 226 v1 Azure keys remain available under their provider-qualified v2 keys.

### Removed mixed-map outputs

The two broad v1 maps are removed. Use a logical full-code-map output or a validated physical-name output according to the migration table.

### Removed metadata output

`resource_metadata` is removed without replacement. Use `resource_label_rules` to inspect effective renderer behavior and `resource_name_errors` to diagnose omitted physical names.

### Physical-name membership

`resource_name` and `resource_name_hashed` include a key only when it has a complete rule and both names validate. Code-only and invalid entries are omitted; `resource_name_errors` explains why.

### Resource-rule schema

The `resource_label_rules` input and output use the typed v2 schema. Partial overrides inherit null attributes from a built-in rule. Empty strings, empty lists, and zero remain explicit values.

### Hash seed

`resource_hash` and hashed physical names can change. The seed now uses `sha256(jsonencode(...))` over structured raw labels plus `resource_hash_values`.

### Context schema

The context adds `schema_version`, `labels_raw`, `resource_rules`, and `resource_code_overrides`. A new v2 context omits the legacy `resource_codes` key. A v2 child ignores inherited v1 rules for physical rendering while preserving them for a later v1 child.

### Azure physical-name composition

All built-in Azure physical-name rules now compose the resource code, `namespace`, `application`, `region_code`, `environment_code`, and `attributes`, in that order, before truncation. A missing or unmapped region remains optional.

For these inputs:

```hcl
namespace   = "platform"
application = "orders"
region      = "eastus"
environment = "production"
attributes  = ["api"]
```

the released v1.2.2 and amended v2 names compare as follows:

| Resource | Released v1.2.2 key and name | Amended v2 key and name |
|---|---|---|
| Resource group | `id_resource["resource_group"] = "rg-platform-orders-ue-p-api"` | `resource_name["azure_resource_group"] = "rg-platform-orders-ue-p-api"` |
| App Service plan | `id_resource["app_service_plan"] = "asp-platform-orders-ue-p-api"` | `resource_name["azure_app_service_plan"] = "asp-platform-orders-ue-p-api"` |

The interim region-free v2 composition existed only in the uncommitted development worktree and was never released. Review every consumed Azure name because other v2 code, hash, and physical-name rule corrections can still change a result or force replacement.

### Context resource-code bridge

A new v2 context chain writes overrides under `resource_code_overrides` and omits `resource_codes`. When v2 consumes v1 context, it preserves the raw legacy `resource_codes` map unchanged for later v1 children and emits a normalized, filtered copy under `resource_code_overrides` for v2 descendants. Prefixed legacy keys win during normalization, while a direct v2 override wins over the inherited v2 copy.

A direct v2 override does not downgrade into a v1 child. Pass the same override directly to that v1 child when it needs it.

### Built-in rule corrections

Corrected physical-name rules can change names and force resource replacement. Review every plan before applying the new source.

### ElastiCache replication-group code

`aws_elasticache_replication_group` changes from the engine-specific `redis` code to `cacherg`.

### Azure code additions

Version 2 adds PostgreSQL Flexible Server and eight Azure Enclave codes. The Enclave entries remain code-only because no complete authoritative physical-name contract is published.

### Legacy single-resource aliases

`id_for_keyvault` and `id_for_storage_account` now resolve provider-qualified keys in `resource_name_hashed`. They remain deprecated throughout v2 and are removed in v3.0.0.

## Output migrations

<!-- BEGIN OUTPUT MIGRATIONS -->
| V1 output | V2 output | Contract |
|---|---|---|
| `id_resource` | `resource_name` | validated physical names |
| `id_resource` | `id_with_resource_code` | logical labels for every resource code |
| `id_resource_unique` | `resource_name_hashed` | hashed validated physical names |
| `resource_label_rules` | `resource_label_rules` | typed v2 rule schema |
| `resource_hash` | `resource_hash` | structured raw-label seed encoding |
<!-- END OUTPUT MIGRATIONS -->

The two v1 mixed-map outputs split because one map cannot represent both logical codes and provider-valid physical names.

## Rule-field migrations

<!-- BEGIN RULE FIELD MIGRATIONS -->
| V1 field | V2 field | Migration |
|---|---|---|
| `code` | `resource_codes` | Move the abbreviation out of the rule object. |
| `code_position` | `code_position` | Direct field. |
| `regex_replace_chars` | `regex_replace_chars` | Direct field. |
| `label_value_case` | `label_value_case` | Direct field. |
| `hash_length` | `hash_length` | Direct field. |
| `required_suffix` | `required_suffix` | Direct field. |
| `trim_chars` | `trim_chars` | Direct field. |
| `collapse_regex` | `collapse_regex` | Direct field. |
| `collapse_replacement` | `collapse_replacement` | Direct field. |
| `delimiter` | `component_delimiter` | Use `group_delimiter` between structured groups. |
| `globally_unique` | `hash_policy = "always"` | Hashing supplies deterministic collision resistance. |
| `include_region` | explicit `label_groups` | Add `region` or `region_code` where the profile needs it. |
| `id_length_limit` | `max_length` | Add `min_length` when the provider requires one. |
<!-- END RULE FIELD MIGRATIONS -->

New v2-only rule fields are `label_groups`, `component_delimiter`, `group_delimiter`, `required_prefix`, `min_length`, `max_length`, `validation_regex`, `forbidden_regexes`, and `hash_policy`.

Rule objects contain only fields used to render or validate a name. They do not contain `code`. Code resolution has three tiers, from lowest to highest precedence: generated AWS codes from `aws_resource_types`, built-in resource codes, and explicit `resource_codes`. Serialized v2 contexts carry explicit overrides under `resource_code_overrides`; a direct v2 override wins over an inherited override.

## AWS code correction

<!-- BEGIN AWS CODE CORRECTIONS -->
| Key | V1 code | V2 code |
|---|---|---|
| `aws_elasticache_replication_group` | `redis` | `cacherg` |
<!-- END AWS CODE CORRECTIONS -->

`cacherg` names the replication group; `redis` names only one supported cache engine. Any logical or physical name that includes the code can change.

## Azure additions and compatibility aliases

### Additions

<!-- BEGIN AZURE ADDITIONS -->
| V2 key | Code |
|---|---|
| `azure_enclave` | `ve` |
| `azure_enclave_community` | `cmt` |
| `azure_enclave_community_endpoint` | `ce` |
| `azure_enclave_connection` | `ec` |
| `azure_enclave_dedicated_hub` | `dh` |
| `azure_enclave_endpoint` | `ee` |
| `azure_enclave_transit_hub` | `th` |
| `azure_enclave_workload` | `wl` |
| `azure_postgresql_flexible_server` | `pgsql` |
<!-- END AZURE ADDITIONS -->

### Compatibility aliases

<!-- BEGIN AZURE COMPATIBILITY ALIASES -->
| Compatibility key | Canonical key |
|---|---|
| `azure_api_management` | `azure_api_management_service` |
| `azure_container_group` | `azure_container_instance` |
| `azure_kubernetes_cluster` | `azure_aks_cluster` |
| `azure_logic_app_integration_account` | `azure_integration_account` |
| `azure_shared_image_gallery` | `azure_gallery` |
| `azure_user_assigned_identity` | `azure_managed_identity` |
<!-- END AZURE COMPATIBILITY ALIASES -->

Compatibility aliases use the same code and effective physical rule as their canonical entry.

## Hash and physical-name changes

The v2 hash seed encodes raw labels and scope values as a structured JSON value. This removes delimiter ambiguity and lets physical-name rules transform the original components exactly once. It also means a v1 hash is not stable across the major upgrade.

`resource_name_hashed` forces the `always` hash policy for supported physical-name keys. The normal and forced-hash names must both validate or the key is omitted from both maps. A per-rule `hash_length` can reserve different headroom than the global `resource_hash_length`.

The two deprecated aliases expose the hash change directly:

<!-- BEGIN LEGACY ALIAS HASH DELTAS -->
| Output | V2 key | Canonical output | V1.2.2 value | V2 value |
|---|---|---|---|---|
| `id_for_keyvault` | `azure_key_vault` | `resource_name_hashed` | `kv-platform-ord-eec9d15d` | `kv-platform-ord-745beb9e` |
| `id_for_storage_account` | `azure_storage_account` | `resource_name_hashed` | `stplatformorderseec9d15d` | `stplatformorders745beb9e` |
<!-- END LEGACY ALIAS HASH DELTAS -->

Each alias equals its provider-qualified entry in `resource_name_hashed`.

## Context compatibility

A v2 context adds:

- `schema_version = 2`
- raw label values under `labels_raw`
- typed, unresolved caller rules under `resource_rules`
- v2 code overrides under `resource_code_overrides`

Legacy normalized label fields stay in the serialized payload. A v2 child that receives v1 context uses those normalized fields, sets `label_source = "legacy_fallback"`, and cannot restore case or characters removed by the v1 parent. Inherited v1 rules are ignored for v2 physical rendering and preserved for v1 children.

A new v2 context omits the legacy `resource_codes` key. A v2 bridge preserves a received v1 map unchanged so a later v1 child keeps the complete v1 code map. A v1 child ignores v2-only `resource_code_overrides`. Avoid mixing v1 and v2 parent contexts in one stack unless the documented fallback and code-bridge behavior is acceptable.

## Name-preservation options

Use one of these approaches when a current physical name must stay unchanged:

1. Keep the stack pinned to its reviewed v1 tag while dependent resources migrate.
2. Pass the current physical name directly to the provider resource.
3. Use a v2 rule override only when the preserved name still satisfies the complete rule.
4. Add the consumed key to `required_resource_names` so an omitted result stops planning.

A Terraform `moved` block changes state addresses. It cannot prevent replacement when a resource keeps the same address but its provider name changes.

## Step-by-step consumer migration

1. Pin the current stack to its exact v1 release.
2. Record every consumed v1 output and resulting physical name.
3. Prefix each Azure resource key with `azure_` and use the tables above for code changes, additions, and compatibility aliases.
4. Replace broad output references with `id_with_resource_code`, `resource_name`, or `resource_name_hashed`.
5. Translate all rule fields with the rule migration table.
6. Add every consumed physical key to `required_resource_names`.
7. Add stable provider-scope values to `resource_hash_values`.
8. Review plans for replacements, including the ElastiCache code and corrected built-in rules.
9. Upgrade one environment at a time.
10. Pin approved stacks to `v2.0.0`.

## Immutable release pinning

`v2.0` adopts future patch releases automatically; `v2.0.0` remains immutable. Existing v1 tags are never moved.

Use a source such as:

```hcl
source = "git::https://github.com/thisjustin816/terraform-null-label.git?ref=v2.0.0"
```

## v1 baseline evidence

The migration tables and tests use the immutable v1 fixture under `test/fixtures/v1-module`:

| Evidence | Value |
|---|---|
| Tag | `v1.2.2` |
| Annotated tag object | `e438758f24ebb4dbb55a9011b884ec8f60b49710` |
| Peeled commit | `895f056322e93c44d51d46547bd90f426b525ed3` |

The fixture manifest records SHA-256 checksums for every vendored runtime file. Contract tests use the fixture to verify v1 key normalization and retained migration behavior.
