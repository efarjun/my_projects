variable "name" {
    description = "Name of policy attackment."
}
variable "policy_arn" {
    description = "ARN of resource to apply to policy attachment."
}
variable "users" {
    description = "List of users to attach policy to."
    type = list
    default = null
}
variable "groups" {
    description = "List of groups to attach policy to."
    type = list
    default = null
}
variable "roles" {
    description = "List of roles to attach policy to."
    type = list
    default = null
}
