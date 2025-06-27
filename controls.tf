##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "aws_securityhub_standards_subscription" "control_subscription" {
  for_each = {
    for standard in try(var.settings.standards_controls, []) : standard.name => standard.standards_arn
  }
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_control_association" "control_assoc" {
  for_each = merge([
    for standard in try(var.settings.standards_controls, []) : {
      for control in try(standard.controls, []) : "${standard.name}-${control.id}" => {
        stardard_name = standard.name
        control       = control
      }
    }
  ]...)
  standards_arn       = aws_securityhub_standards_subscription.control_subscription[each.value.stardard_name].standards_arn
  security_control_id = each.value.control.id
  association_status  = each.value.control.status
  updated_reason      = try(each.value.control.reason, null)
  depends_on          = [aws_securityhub_standards_subscription.control_subscription]
}
