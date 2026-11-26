##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

# Plan-only tests with a mocked AWS provider: they run in CI without cloud credentials.

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }

  mock_data "aws_organizations_organization" {
    defaults = {
      roots = [
        {
          id           = "r-abcd"
          arn          = "arn:aws:organizations::111122223333:root/o-example/r-abcd"
          name         = "Root"
          policy_types = []
        }
      ]
    }
  }

  mock_resource "aws_securityhub_configuration_policy" {
    defaults = {
      id = "a1b2c3d4-5678-90ab-cdef-111122223333"
    }
  }

  mock_data "aws_organizations_organizational_unit" {
    defaults = {
      id = "ou-abcd-workload"
    }
  }
}

variables {
  org = {
    organization_name = "example"
    organization_unit = "security"
    environment_type  = "production"
    environment_name  = "prod"
  }
}

run "defaults_enable_security_hub_only" {
  command = plan

  assert {
    condition = alltrue([
      aws_securityhub_account.this.enable_default_standards == null,
      aws_securityhub_account.this.auto_enable_controls == null,
    ])
    error_message = "With empty settings the account attributes must be left unset so the provider defaults apply."
  }

  assert {
    condition = alltrue([
      length(aws_securityhub_organization_admin_account.this) == 0,
      length(aws_securityhub_organization_configuration.this) == 0,
      length(aws_securityhub_finding_aggregator.this) == 0,
      length(aws_securityhub_standards_subscription.control_subscription) == 0,
      length(aws_securityhub_configuration_policy.central_policy) == 0,
      length(data.aws_organizations_organization.current) == 0,
    ])
    error_message = "With empty settings only aws_securityhub_account must be planned."
  }
}

run "account_settings_passthrough" {
  command = plan

  variables {
    settings = {
      enable_default_standards  = false
      control_finding_generator = "STANDARD_CONTROL"
      auto_enable_controls      = false
    }
  }

  assert {
    condition     = aws_securityhub_account.this.enable_default_standards == false
    error_message = "enable_default_standards must be passed through."
  }

  assert {
    condition     = aws_securityhub_account.this.control_finding_generator == "STANDARD_CONTROL"
    error_message = "control_finding_generator must be passed through."
  }

  assert {
    condition     = aws_securityhub_account.this.auto_enable_controls == false
    error_message = "auto_enable_controls must be passed through."
  }
}

run "delegated_administrator" {
  command = plan

  variables {
    organization_account_id = "111122223333"
    settings = {
      organization = {
        delegated = true
      }
    }
  }

  assert {
    condition     = length(aws_securityhub_organization_admin_account.this) == 1
    error_message = "The delegated administrator must be registered when organization.delegated is true."
  }

  assert {
    condition     = aws_securityhub_organization_admin_account.this[0].admin_account_id == "111122223333"
    error_message = "admin_account_id must come from organization_account_id."
  }

  assert {
    condition     = length(aws_securityhub_organization_configuration.this) == 0
    error_message = "The organization configuration must not be managed from the management account step."
  }
}

run "finding_aggregator" {
  command = plan

  variables {
    settings = {
      aggregator = {
        enabled      = true
        linking_mode = "SPECIFIED_REGIONS"
        regions      = ["us-west-2", "eu-west-1"]
      }
    }
  }

  assert {
    condition     = length(aws_securityhub_finding_aggregator.this) == 1
    error_message = "The finding aggregator must be created when aggregator.enabled is true."
  }

  assert {
    condition     = aws_securityhub_finding_aggregator.this[0].linking_mode == "SPECIFIED_REGIONS"
    error_message = "linking_mode must be passed through."
  }

  assert {
    condition     = toset(aws_securityhub_finding_aggregator.this[0].specified_regions) == toset(["us-west-2", "eu-west-1"])
    error_message = "regions must be passed as specified_regions."
  }
}

run "finding_aggregator_default_linking_mode" {
  command = plan

  variables {
    settings = {
      aggregator = {
        enabled = true
      }
    }
  }

  assert {
    condition     = aws_securityhub_finding_aggregator.this[0].linking_mode == "ALL_REGIONS"
    error_message = "linking_mode must default to ALL_REGIONS."
  }
}

run "standards_and_control_overrides" {
  command = plan

  variables {
    settings = {
      standards_controls = [
        {
          name          = "fsbp"
          standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
          controls = [
            {
              id     = "IAM.6"
              status = "DISABLED"
              reason = "Hardware MFA not used"
            },
            {
              id     = "S3.1"
              status = "ENABLED"
            },
          ]
        },
        {
          name          = "cis"
          standards_arn = "arn:aws:securityhub:us-east-1::standards/cis-aws-foundations-benchmark/v/3.0.0"
        },
      ]
    }
  }

  assert {
    condition     = toset(keys(aws_securityhub_standards_subscription.control_subscription)) == toset(["fsbp", "cis"])
    error_message = "One standards subscription per standards_controls entry is expected, keyed by name."
  }

  assert {
    condition     = toset(keys(aws_securityhub_standards_control_association.control_assoc)) == toset(["fsbp-IAM.6", "fsbp-S3.1"])
    error_message = "One control association per control override is expected, keyed by <standard>-<control>."
  }

  assert {
    condition = alltrue([
      aws_securityhub_standards_control_association.control_assoc["fsbp-IAM.6"].association_status == "DISABLED",
      aws_securityhub_standards_control_association.control_assoc["fsbp-IAM.6"].updated_reason == "Hardware MFA not used",
      aws_securityhub_standards_control_association.control_assoc["fsbp-S3.1"].association_status == "ENABLED",
      aws_securityhub_standards_control_association.control_assoc["fsbp-S3.1"].updated_reason == null,
    ])
    error_message = "Control status and reason must be passed through; reason defaults to null."
  }
}

run "central_configuration_root_policy" {
  command = plan

  variables {
    settings = {
      aggregator = {
        enabled = true
      }
      organization = {
        enabled               = true
        auto_enable           = false
        auto_enable_standards = "NONE"
        configuration_type    = "CENTRAL"
      }
      configuration_policies = [
        {
          name            = "baseline"
          description     = "Organization baseline"
          service_enabled = true
          enabled_standard_arns = [
            "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0",
          ]
          controls_configuration = {
            disabled_control_identifiers = ["CloudTrail.2"]
            custom_parameters = [
              {
                security_control_id = "ACM.1"
                parameters = [
                  {
                    name       = "daysToExpiration"
                    value_type = "CUSTOM"
                    int        = 30
                  },
                ]
              },
            ]
          }
        },
      ]
    }
  }

  assert {
    condition     = aws_securityhub_organization_configuration.this[0].organization_configuration[0].configuration_type == "CENTRAL"
    error_message = "The organization configuration must use CENTRAL configuration_type."
  }

  assert {
    condition     = aws_securityhub_organization_configuration.this[0].auto_enable_standards == "NONE"
    error_message = "auto_enable_standards must be passed through."
  }

  assert {
    condition     = keys(aws_securityhub_configuration_policy.central_policy) == ["baseline"]
    error_message = "The central configuration policy must be created."
  }

  assert {
    condition     = aws_securityhub_configuration_policy.central_policy["baseline"].configuration_policy[0].security_controls_configuration[0].disabled_control_identifiers == toset(["CloudTrail.2"])
    error_message = "disabled_control_identifiers must be passed through."
  }

  assert {
    condition     = flatten([for cp in aws_securityhub_configuration_policy.central_policy["baseline"].configuration_policy[0].security_controls_configuration[0].security_control_custom_parameter : [for param in cp.parameter : [for v in param.int : v.value]]]) == [30]
    error_message = "Typed custom parameter values must render the matching block."
  }

  assert {
    condition     = length(flatten([for cp in aws_securityhub_configuration_policy.central_policy["baseline"].configuration_policy[0].security_controls_configuration[0].security_control_custom_parameter : [for param in cp.parameter : param.string]])) == 0
    error_message = "Only the typed block that is set must be rendered."
  }

  assert {
    condition     = aws_securityhub_configuration_policy_association.central_policy_org["baseline"].target_id == "r-abcd"
    error_message = "Policies must be associated with the organization root by default."
  }
}

run "central_configuration_scoped_targets" {
  command = plan

  variables {
    settings = {
      aggregator = {
        enabled = true
      }
      organization = {
        enabled               = true
        auto_enable           = false
        auto_enable_standards = "NONE"
        configuration_type    = "CENTRAL"
        account_ids           = ["444455556666"]
        org_unit_ids          = ["ou-abcd-12345678"]
        org_unit_names        = ["Workloads"]
      }
      configuration_policies = [
        {
          name                  = "workloads"
          service_enabled       = true
          enabled_standard_arns = ["arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"]
          controls_configuration = {
            enabled_control_identifiers = ["*"]
          }
          associations = {
            root      = false
            org_units = true
          }
        },
        {
          name            = "sandbox-disabled"
          service_enabled = false
          associations = {
            root     = false
            accounts = true
          }
        },
      ]
    }
  }

  assert {
    condition     = length(aws_securityhub_configuration_policy_association.central_policy_org) == 0
    error_message = "No root association is expected when associations.root is false."
  }

  assert {
    condition     = aws_securityhub_configuration_policy_association.central_policy_orgunit["workloads-ou-abcd-12345678"].target_id == "ou-abcd-12345678"
    error_message = "org_unit_ids must be associated with policies that set associations.org_units."
  }

  assert {
    condition     = aws_securityhub_configuration_policy_association.central_policy_orgunit_name["workloads-Workloads"].target_id == "ou-abcd-workload"
    error_message = "org_unit_names must be resolved to OU IDs and associated."
  }

  assert {
    condition     = keys(aws_securityhub_configuration_policy_association.central_policy_acct) == ["sandbox-disabled-444455556666"]
    error_message = "account_ids must be associated only with policies that set associations.accounts."
  }

  assert {
    condition     = length(aws_securityhub_configuration_policy.central_policy["sandbox-disabled"].configuration_policy[0].security_controls_configuration) == 0
    error_message = "No controls configuration block is expected when controls_configuration is omitted."
  }
}

run "local_configuration_skips_policies" {
  command = plan

  variables {
    settings = {
      organization = {
        enabled            = true
        configuration_type = "LOCAL"
        account_ids        = ["444455556666"]
        org_unit_ids       = ["ou-abcd-12345678"]
      }
      configuration_policies = [
        {
          name            = "ignored"
          service_enabled = true
          associations = {
            root      = true
            accounts  = true
            org_units = true
          }
        },
      ]
    }
  }

  assert {
    condition     = length(aws_securityhub_configuration_policy.central_policy) == 0
    error_message = "Configuration policies must only be created with CENTRAL configuration_type."
  }

  assert {
    condition     = length(aws_securityhub_configuration_policy_association.central_policy_org) == 0
    error_message = "Policy associations must only be created with CENTRAL configuration_type."
  }

  assert {
    condition = alltrue([
      length(aws_securityhub_configuration_policy_association.central_policy_acct) == 0,
      length(aws_securityhub_configuration_policy_association.central_policy_orgunit) == 0,
    ])
    error_message = "Account and OU policy associations must only be created with CENTRAL configuration_type."
  }

  assert {
    condition     = length(data.aws_organizations_organization.current) == 0
    error_message = "The organization lookup must be skipped when CENTRAL configuration is not used."
  }
}

run "invalid_spoke_def_rejected" {
  command = plan

  variables {
    spoke_def = "1"
  }

  expect_failures = [
    var.spoke_def,
  ]
}
