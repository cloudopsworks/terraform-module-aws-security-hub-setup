##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "securityhub_arn" {
  value = try(aws_securityhub_account.this[0].arn, null)
}