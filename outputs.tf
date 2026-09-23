##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "securityhub_arn" {
  description = "ARN of the Security Hub account resource (hub) enabled in the current account and region."
  value       = try(aws_securityhub_account.this.arn, null)
}
