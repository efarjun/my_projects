variable "name" {
    description = "Name of policy attackment."
}
variable "users" {
    description = "List of users to attach policy to."
    default = null
}
variable "groups" {
    description = "List of groups to attach policy to."
    default = null
}
variable "roles" {
    description = "List of roles to attach policy to."
    default = null
}
variable "policy_arn" {
    description = "ARN of the policy to attach."
}
