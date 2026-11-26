##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## Security Hub configuration settings.
## Uncomment "settings:" together with the keys you need; a bare "settings:" with no keys evaluates to null.
#
# settings:                                   # (Optional) Security Hub configuration object. Default: {}.
# enable_default_standards: true            # (Optional) Subscribe the account to the AWS default standards on enablement. Default: true (provider default).
# control_finding_generator: "SECURITY_CONTROL" # (Optional) Valid values: "SECURITY_CONTROL" (consolidated findings) | "STANDARD_CONTROL" (one finding per standard). Default: provider default.
# auto_enable_controls: true                # (Optional) Automatically enable new controls added to enabled standards. Default: true (provider default).
## AWS Organizations integration. "delegated" is applied from the management account;
## "enabled" and the remaining keys are applied from the delegated administrator account.
#
# organization:                             # (Optional) AWS Organizations integration. Default: {} (disabled).
# delegated: false                        # (Optional) Register organization_account_id as the delegated administrator (management account only). Default: false.
# enabled: false                          # (Optional) Manage the organization configuration (delegated administrator account only). Default: false.
# auto_enable: false                      # (Optional) Auto-enable Security Hub for new member accounts. Must be false with "CENTRAL". Default: false.
# auto_enable_standards: "NONE"           # (Optional) Valid values: "DEFAULT" | "NONE". Must be "NONE" with "CENTRAL". Default: provider default.
# configuration_type: "CENTRAL"           # (Optional) Valid values: "CENTRAL" | "LOCAL". "CENTRAL" requires aggregator.enabled and is required for configuration_policies. Default: unset.
# account_ids:                            # (Optional) Member account IDs for policies with associations.accounts = true. Default: [].
# - "123456789012"
# org_unit_ids:                           # (Optional) OU IDs for policies with associations.org_units = true. Default: [].
# - "ou-abcd-12345678"
# org_unit_names:                         # (Optional) First-level OU names (children of the org root), resolved to IDs; used with associations.org_units = true. Default: [].
# - "Workloads"
# aggregator:                               # (Optional) Cross-region finding aggregator, created in the current (home) region. Default: {} (disabled).
# enabled: false                          # (Optional) Create the finding aggregator. Default: false.
# linking_mode: "ALL_REGIONS"             # (Optional) Valid values: "ALL_REGIONS" | "ALL_REGIONS_EXCEPT_SPECIFIED" | "SPECIFIED_REGIONS" | "NO_REGIONS". Default: "ALL_REGIONS".
# regions:                                # (Optional) Required for "SPECIFIED_REGIONS" / "ALL_REGIONS_EXCEPT_SPECIFIED". Default: null.
# - "us-west-2"
# - "eu-west-1"
## Standards subscribed in this account. Standard ARNs are region-specific.
#
# standards_controls:                       # (Optional) Standards subscriptions for this account, with per-control overrides. Default: [].
# - name: "fsbp"                          # (Required) Unique key for this standard within the module.
# standards_arn: "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0" # (Required) Standard ARN (region-specific).
# controls:                             # (Optional) Per-control association overrides. Default: [].
# - id: "IAM.6"                       # (Required) Security control ID, e.g. "IAM.6", "S3.1".
# status: "DISABLED"                # (Required) Valid values: "ENABLED" | "DISABLED".
# reason: "Hardware MFA not used"   # (Optional) Required by AWS when status is "DISABLED". Default: null.
## Central configuration policies. Created only when organization.configuration_type is "CENTRAL".
#
# configuration_policies:                   # (Optional) Central configuration policies. Default: [].
# - name: "baseline"                      # (Required) Unique policy name.
# description: "Organization baseline"  # (Optional) Policy description. Default: null.
# service_enabled: true                 # (Required) Enable (true) or disable (false) Security Hub in targeted accounts.
# enabled_standard_arns:                # (Optional) Standards to enable; required when service_enabled is true. Default: null.
# - "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
# - "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/3.0.0"
# controls_configuration:               # (Optional) Control configuration; required when service_enabled is true. Default: {}.
## Set exactly one of enabled_control_identifiers or disabled_control_identifiers; they conflict.
## Use enabled_control_identifiers: ["*"] to enable every control.
#
# enabled_control_identifiers:        # (Optional) Controls to enable. Default: null.
# - "*"
# disabled_control_identifiers:       # (Optional) Controls to disable. Default: null.
# - "CloudTrail.2"
# custom_parameters:                  # (Optional) Custom control parameters. Default: [].
# - security_control_id: "ACM.1"    # (Required) Security control ID.
# parameters:                     # (Required) Parameter list.
# - name: "daysToExpiration"    # (Required) Parameter name as defined by the control.
# value_type: "CUSTOM"        # (Required) Valid values: "DEFAULT" | "CUSTOM".
# int: 15                     # (Optional) Exactly one typed value: bool | double | enum | enum_list | int | int_list | string | string_list.
# associations:                         # (Optional) Policy targets. Default: {}.
# root: true                          # (Optional) Attach to the organization root. Default: true.
# accounts: false                     # (Optional) Attach to each organization.account_ids entry. Default: false.
# org_units: false                    # (Optional) Attach to each organization.org_unit_ids / org_unit_names entry. Default: false.
variable "settings" {
  description = "(Optional) Security Hub configuration settings: account enablement, organization, aggregator, standards/controls and central configuration policies. Default: {}."
  type        = any
  default     = {}
}

# organization_account_id: "123456789012"     # (Optional) 12-digit delegated administrator account ID; used only when settings.organization.delegated is true. Default: "".
variable "organization_account_id" {
  description = "(Optional) AWS account ID of the Security Hub delegated administrator account, used when settings.organization.delegated is true. Default: \"\"."
  type        = string
  default     = ""
}
