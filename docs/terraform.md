## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | cloudopsworks/tags/local | 1.0.9 |

## Resources

| Name | Type |
|------|------|
| [aws_securityhub_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) | resource |
| [aws_securityhub_configuration_policy.central_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy) | resource |
| [aws_securityhub_configuration_policy_association.central_policy_acct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_configuration_policy_association.central_policy_org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_configuration_policy_association.central_policy_orgunit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_configuration_policy_association.central_policy_orgunit_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_finding_aggregator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator) | resource |
| [aws_securityhub_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_securityhub_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) | resource |
| [aws_securityhub_standards_control_association.control_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_control_association) | resource |
| [aws_securityhub_standards_subscription.control_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_organizations_organizational_unit.org_unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organizational_unit) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | Extra tags to add to the resources | `map(string)` | `{}` | no |
| <a name="input_is_hub"></a> [is\_hub](#input\_is\_hub) | Is this a hub or spoke configuration? | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | Organization details | <pre>object({<br/>    organization_name = string<br/>    organization_unit = string<br/>    environment_type  = string<br/>    environment_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_organization_account_id"></a> [organization\_account\_id](#input\_organization\_account\_id) | The AWS account ID of the Security Hub administrator account | `string` | `""` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Settings for the configuration recorder | `any` | `{}` | no |
| <a name="input_spoke_def"></a> [spoke\_def](#input\_spoke\_def) | Spoke ID Number, must be a 3 digit number | `string` | `"001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityhub_arn"></a> [securityhub\_arn](#output\_securityhub\_arn) | n/a |
