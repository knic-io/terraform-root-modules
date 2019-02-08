variable "dev_account_user_names" {
  type        = "list"
  description = "IAM user names to grant access to the `dev` account"
  default     = []
}

module "kops_admin_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "dev") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "admin"
  attributes        = "kubernetes"
  role_name         = "${var.kubernetes_admin_role_name}"
  user_names        = "${var.dev_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.dev_account_id}"
  require_mfa       = "true"
}

module "kops_readonly_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "dev") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "readonly"
  attributes        = "kubernetes"
  role_name         = "${var.kubernetes_readonly_role_name}"
  user_names        = "${var.dev_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.dev_account_id}"
  require_mfa       = "true"
}

# Provision group access to dev account
module "organization_access_group_dev" {
  source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-group.git?ref=tags/0.3.0"
  enabled           = "${contains(var.accounts_enabled, "dev") == true ? "true" : "false"}"
  namespace         = "${var.namespace}"
  stage             = "dev"
  name              = "admin"
  user_names        = "${var.dev_account_user_names}"
  member_account_id = "${data.terraform_remote_state.accounts.dev_account_id}"
  require_mfa       = "true"
}

module "organization_access_group_ssm_dev" {
  source  = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  enabled = "${contains(var.accounts_enabled, "dev") == true ? "true" : "false"}"

  parameter_write = [
    {
      name        = "/${var.namespace}/dev/admin_group"
      value       = "${module.organization_access_group_dev.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM admin group name for the 'dev' account"
    },
    {
      name        = "/${var.namespace}/dev/kubernetes_admin_group"
      value       = "${module.kops_admin_access_group_dev.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM kubernetes admin group name for the 'dev' account"
    },
    {
      name        = "/${var.namespace}/dev/kubernetes_readonly_group"
      value       = "${module.kops_readonly_access_group_dev.group_name}"
      type        = "String"
      overwrite   = "true"
      description = "IAM kubernetes readonly group name for the 'dev' account"
    },
  ]
}

output "dev_switchrole_url" {
  description = "URL to the IAM console to switch to the dev account organization access role"
  value       = "${module.organization_access_group_dev.switchrole_url}"
}
