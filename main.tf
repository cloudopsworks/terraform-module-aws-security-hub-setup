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
  count            = var.organization_account_id != "" && var.organization_account_id != data.aws_caller_identity.current.account_id ? 1 : 0
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

resource "aws_organizations_delegated_administrator" "this" {
  count             = var.organization_account_id != "" && var.organization_account_id != data.aws_caller_identity.current.account_id ? 1 : 0
  account_id        = var.organization_account_id
  service_principal = "securityhub.amazonaws.com"
}

