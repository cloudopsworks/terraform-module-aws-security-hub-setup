##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

resource "aws_securityhub_account" "this" {
  count                     = try(var.settings.organization.enabled, false) ? 0 : 1
  enable_default_standards  = try(var.settings.enable_default_standards, null)
  control_finding_generator = try(var.settings.control_finding_generator, null)
  auto_enable_controls      = try(var.settings.auto_enable_controls, null)
}

resource "aws_securityhub_organization_admin_account" "this" {
  count            = try(var.settings.organization.delegated, false) ? 1 : 0
  admin_account_id = var.organization_account_id
}

resource "aws_securityhub_organization_configuration" "this" {
  depends_on            = [aws_securityhub_organization_admin_account.this]
  count                 = try(var.settings.organization.enabled, false) ? 1 : 0
  auto_enable           = try(var.settings.organization.auto_enable, false)
  auto_enable_standards = try(var.settings.organization.auto_enable_standards, null)
  dynamic "organization_configuration" {
    for_each = try(var.settings.organization.configuration_type, "") != "" ? [1] : []
    content {
      configuration_type = try(var.settings.organization.configuration_type, null)
    }
  }
}

resource "aws_securityhub_finding_aggregator" "this" {
  count             = try(var.settings.aggregator.enabled, false) ? 1 : 0
  linking_mode      = try(var.settings.aggregator.linking_mode, "ALL_REGIONS")
  specified_regions = try(var.settings.aggregator.regions, null)
}

resource "aws_securityhub_configuration_policy" "central_policy" {
  depends_on = [aws_securityhub_organization_configuration.this]
  for_each = {
    for item in try(var.settings.configuration_policies, []) : item.name => item
    if try(var.settings.aggregator.enabled, false) && try(var.settings.organization.configuration_type, "") == "CENTRAL"
  }
  name        = each.value.name
  description = try(each.value.description, null)
  configuration_policy {
    service_enabled       = each.value.service_enabled
    enabled_standard_arns = try(each.value.enabled_standard_arns, null)
    dynamic "security_controls_configuration" {
      for_each = length(try(each.value.controls_configuration, {})) > 0 ? [1] : []
      content {
        disabled_control_identifiers = try(each.value.controls_configuration.disabled_control_identifiers, null)
        enabled_control_identifiers  = try(each.value.controls_configuration.enabled_control_identifiers, null)
        dynamic "security_control_custom_parameter" {
          for_each = try(each.value.controls_configuration.custom_parameters, [])
          content {
            security_control_id = security_control_custom_parameter.value.security_control_id
            dynamic "parameter" {
              for_each = try(security_control_custom_parameter.value.parameters, [])
              content {
                name       = parameter.value.name
                value_type = parameter.value.value_type
                dynamic "bool" {
                  for_each = try(parameter.value.bool, null) != null ? [1] : []
                  content {
                    value = parameter.value.bool
                  }
                }
                dynamic "double" {
                  for_each = try(parameter.value.double, null) != null ? [1] : []
                  content {
                    value = parameter.value.double
                  }
                }
                dynamic "enum" {
                  for_each = try(parameter.value.enum, null) != null ? [1] : []
                  content {
                    value = parameter.value.enum
                  }
                }
                dynamic "enum_list" {
                  for_each = try(parameter.value.enum_list, null) != null ? [1] : []
                  content {
                    value = parameter.value.enum_list
                  }
                }
                dynamic "int" {
                  for_each = try(parameter.value.int, null) != null ? [1] : []
                  content {
                    value = parameter.value.int
                  }
                }
                dynamic "int_list" {
                  for_each = try(parameter.value.int_list, null) != null ? [1] : []
                  content {
                    value = parameter.value.int_list
                  }
                }
                dynamic "string" {
                  for_each = try(parameter.value.string, null) != null ? [1] : []
                  content {
                    value = parameter.value.string
                  }
                }
                dynamic "string_list" {
                  for_each = try(parameter.value.string_list, null) != null ? [1] : []
                  content {
                    value = parameter.value.string_list
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_securityhub_configuration_policy_association" "central_policy" {
  for_each = merge([
    for item in try(var.settings.configuration_policies, []) : {
      for account in var.settings.organization.account_ids : "${item.name}-${account}" => {
        config_name = item.name
        account_id  = account
      }
    } if try(var.settings.aggregator.enabled, false) && try(var.settings.organization.configuration_type, "") == "CENTRAL"
  ])
  policy_id = aws_securityhub_configuration_policy.central_policy[each.value.config_name].id
  target_id = each.value.account_id
}