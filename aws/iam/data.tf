variable "data_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `data` account"
  default     = []
}

module "kops_admin_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "admin"
  attributes        = "kubernetes"
  role_name         = "${var.kubernetes_admin_role_name}"
  user_names        = "${var.data_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "readonly"
  attributes        = "kubernetes"
  role_name         = "${var.kubernetes_readonly_role_name}"
  user_names        = "${var.data_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}

# Provision group access to data account
module "organization_access_group_data" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "data"
  name              = "admin"
  user_names        = "${var.data_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.data_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_data" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "data") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/data/admin_group"
      value       = "${module.organization_access_group_data.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'data' account"
    },
    {
      name        = "/${var.namespace}/data/kubernetes_admin_group"
      value       = "${module.kops_admin_access_group_data.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM kubernetes admin group name for the 'data' account"
    },
    {
      name        = "/${var.namespace}/data/kubernetes_readonly_group"
      value       = "${module.kops_readonly_access_group_data.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM kubernetes readonly group name for the 'data' account"
    },
  ]
}

output "data_switchrole_url" {
  description = "URL to the IAM console to switch to the data account organization access role"
  value       = "${module.organization_access_group_data.switchrole_url}"
}
