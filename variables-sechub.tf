##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

## Settings configuration as YAML
#settings:
#  control_finding_generator: "STANDARD_CONTROL"
#  enable_default_standards: true | false
#  organization:
#    enabled: true | false
#    auto_enable: true | false
#    auto_enable_standards: "NONE" | "ALL"
#    configuration_type: "CENTRAL" | "LOCAL"
#    account_ids:
#      - "123456789012"
#      - "098765432109"
#    org_unit_ids:
#      - "ou-1234-5678"
#    org_unit_names:
#      - "Development"
#  aggregator:
#    enabled: true | false
#    linking_mode: "ALL_REGIONS" | "SPECIFIED_REGIONS"
#    regions:
#      - "us-west-2"
#      - "us-east-2"
#  standards_controls: []
#  configuration_policies:
#    - name: "policy_name"
#      description: "Policy description"
#      service_enabled: true | false
#      enabled_standard_arns:  # List of enabled standard ARNs
#        - "arn:aws:securityhub:us-west-2::standards/standard_name"
#      controls_configuration: # Configuration for security controls
#        enabled_control_identifiers:  # List of enabled control identifiers
#          - "control_id_1"
#          - "control_id_2"
#        disabled_control_identifiers:  # List of disabled control identifiers
#          - "control_id_3"
#          - "control_id_4"
#          - "control_id_5"
#      custom_parameters:  # Custom parameters for security controls
#        - security_control_id: "control_id_1"
#          parameters:
#            - name: "parameter_name"
#              value_type: bool | double | enum | enum_list | int | int_list | string | string_list
#              bool: <bool value>
#              double: <double value>
#              enum: <enum value>
#              enum_list: [<enum value1>, <enum value2>]
#              int: <int value>
#              int_list: [<int value1>, <int value2>]
#              string: <string value>
#              string_list: [<string value1>, <string value2>]
#      associations:
#        root: true | false $ defaults to true
#        accounts: true | False # defaults to false
#        org_units: true | false # defaults to false
variable "settings" {
  description = "Settings for the configuration recorder"
  type        = any
  default     = {}
}

variable "organization_account_id" {
  description = "The AWS account ID of the Security Hub administrator account"
  type        = string
  default     = ""
}