##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

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