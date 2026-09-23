##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## Settings configuration as YAML
# settings:
#   enable_default_standards: true             # (Optional) Subscribe the account to the AWS default standards when Security Hub is enabled. Default: true (provider default).
#   control_finding_generator: "SECURITY_CONTROL" # (Optional) How control findings are generated. Valid values: "SECURITY_CONTROL" (consolidated findings) | "STANDARD_CONTROL" (one finding per standard). Default: provider default.
#   auto_enable_controls: true                 # (Optional) Automatically enable new controls added to enabled standards. Default: true (provider default).
#   organization:                              # (Optional) AWS Organizations integration. Default: {} (disabled).
#     delegated: false                         # (Optional) Designate `organization_account_id` as the Security Hub delegated administrator. Run from the Organizations management account. Default: false.
#     enabled: false                           # (Optional) Manage the organization configuration (run from the delegated administrator account). Default: false.
#     auto_enable: false                       # (Optional) Automatically enable Security Hub for new member accounts. Must be false when configuration_type is "CENTRAL". Default: false.
#     auto_enable_standards: "NONE"            # (Optional) Automatically enable default standards on new member accounts. Valid values: "DEFAULT" | "NONE". Must be "NONE" when configuration_type is "CENTRAL". Default: provider default.
#     configuration_type: "CENTRAL"            # (Optional) Organization configuration mode. Valid values: "CENTRAL" | "LOCAL". "CENTRAL" is required for configuration_policies. Requires the finding aggregator. Default: unset.
#     account_ids:                             # (Optional) Member account IDs targeted by policies with associations.accounts = true. Default: [].
#       - "123456789012"
#     org_unit_ids:                            # (Optional) Organizational unit IDs targeted by policies with associations.org_units = true. Default: [].
#       - "ou-abcd-12345678"
#     org_unit_names:                          # (Optional) Names of first-level OUs (direct children of the organization root) resolved to IDs and targeted by policies with associations.org_units = true. Default: [].
#       - "Workloads"
#   aggregator:                                # (Optional) Cross-region finding aggregator. Default: {} (disabled).
#     enabled: false                           # (Optional) Create the finding aggregator in the current (home) region. Default: false.
#     linking_mode: "ALL_REGIONS"              # (Optional) Valid values: "ALL_REGIONS" | "ALL_REGIONS_EXCEPT_SPECIFIED" | "SPECIFIED_REGIONS" | "NO_REGIONS". Default: "ALL_REGIONS".
#     regions:                                 # (Optional) Regions to include/exclude; required for "SPECIFIED_REGIONS" and "ALL_REGIONS_EXCEPT_SPECIFIED". Default: null.
#       - "us-west-2"
#   standards_controls:                        # (Optional) Standards subscriptions for the current account, with per-control overrides. Default: [].
#     - name: "fsbp"                           # (Required) Unique key for this standard within the module.
#       standards_arn: "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0" # (Required) ARN of the standard to subscribe to.
#       controls:                              # (Optional) Per-control association overrides. Default: [].
#         - id: "IAM.6"                        # (Required) Security control ID (e.g. "IAM.6", "S3.1").
#           status: "DISABLED"                 # (Required) Valid values: "ENABLED" | "DISABLED".
#           reason: "Hardware MFA not used"    # (Optional) Reason for the change; required by AWS when status is "DISABLED". Default: null.
#   configuration_policies:                    # (Optional) Central configuration policies; only created when organization.configuration_type is "CENTRAL". Default: [].
#     - name: "baseline"                       # (Required) Unique policy name.
#       description: "Org baseline"            # (Optional) Policy description. Default: null.
#       service_enabled: true                  # (Required) Whether Security Hub is enabled in the targeted accounts.
#       enabled_standard_arns:                 # (Optional) Standards enabled by the policy; required when service_enabled is true. Default: null.
#         - "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
#       controls_configuration:                # (Optional) Control configuration; required when service_enabled is true. Default: {}.
#         enabled_control_identifiers: []      # (Optional) Controls to enable; conflicts with disabled_control_identifiers. Use ["*"] to enable all. Default: null.
#         disabled_control_identifiers:        # (Optional) Controls to disable; conflicts with enabled_control_identifiers. Default: null.
#           - "CloudTrail.2"
#         custom_parameters:                   # (Optional) Custom control parameters. Default: [].
#           - security_control_id: "ACM.1"     # (Required) Security control ID.
#             parameters:                      # (Required) Parameters for the control.
#               - name: "daysToExpiration"     # (Required) Parameter name.
#                 value_type: "CUSTOM"         # (Required) Valid values: "DEFAULT" | "CUSTOM".
#                 int: 15                      # (Optional) Set exactly one typed value matching the parameter: bool | double | enum | enum_list | int | int_list | string | string_list.
#       associations:                          # (Optional) Where the policy is attached. Default: {}.
#         root: true                           # (Optional) Attach to the organization root. Default: true.
#         accounts: false                      # (Optional) Attach to each organization.account_ids entry. Default: false.
#         org_units: false                     # (Optional) Attach to each organization.org_unit_ids / org_unit_names entry. Default: false.
variable "settings" {
  description = "(Optional) Security Hub configuration settings: account enablement, organization, aggregator, standards/controls and central configuration policies. Default: {}."
  type        = any
  default     = {}
}

# organization_account_id: "123456789012" # (Optional) AWS account ID designated as the Security Hub delegated administrator; used only when settings.organization.delegated is true. Default: "".
variable "organization_account_id" {
  description = "(Optional) AWS account ID of the Security Hub delegated administrator account, used when settings.organization.delegated is true. Default: \"\"."
  type        = string
  default     = ""
}
