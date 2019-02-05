variable "cluster_id" {
  type        = "string"
  description = "A unique-per-cluster identifier to prevent replay attacks. Good choices are a random token or a domain name that will be unique to your cluster"
}

variable "kube_config_path" {
  type        = "string"
  description = "Path to the kube config file. Can be sourced from `KUBE_CONFIG` or `KUBECONFIG`"
}

variable "admin_iam_role_arn" {
  type        = "string"
  description = "IAM Role with admin permissions to map to `admin_k8s_username`"
}

variable "admin_k8s_username" {
  type        = "string"
  description = "Kubernetes admin username to be mapped to `admin_iam_role_arn`"
  default     = ""
}

variable "admin_k8s_groups" {
  type        = "list"
  description = "List of Kubernetes groups to be mapped to `admin_iam_role_arn`"
  default     = []
}

variable "readonly_iam_role_arn" {
  type        = "string"
  description = "IAM Role with readonly permissions to map to `readonly_k8s_username`"
}

variable "readonly_k8s_username" {
  type        = "string"
  description = "Kubernetes readonly username to be mapped to `readonly_iam_role_arn`"
  default     = ""
}

variable "readonly_k8s_groups" {
  type        = "list"
  description = "List of Kubernetes groups to be mapped to `readonly_iam_role_arn`"
  default     = []
}

module "iam_authenticator_config" {
  source                = "git::https://github.com/cloudposse/terraform-aws-kops-iam-authenticator-config.git?ref=tags/0.1.1"
  cluster_id            = "${var.cluster_id}"
  kube_config_path      = "${var.kube_config_path}"
  admin_iam_role_arn    = "${var.admin_iam_role_arn}"
  admin_k8s_username    = "${var.admin_k8s_username}"
  admin_k8s_groups      = "${var.admin_k8s_groups}"
  readonly_iam_role_arn = "${var.readonly_iam_role_arn}"
  readonly_k8s_username = "${var.readonly_k8s_username}"
  readonly_k8s_groups   = "${var.readonly_k8s_groups}"
}
