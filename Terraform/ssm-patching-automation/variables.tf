variable "document_name" {
  default =  "EC2-Patching-Automation"
}
variable "document_format" {
  default = "YAML"
}
variable "document_type" {
  default = "Automation"
}
variable "window_name" {
  default = "EC2-Patching-Maintenance"
}
variable "cron_schedule" {
  default = "cron(0 */30 * * * ? *)"
}
variable "window_duration" {
  default = 3
}
variable "window_cutoff" {
  default = 1
}
variable "target_id" {
  default = "aws_ssm_maintenance_window.ec2-patch-window.id"
}
variable "target_name" {
  default = "EC2-Patching-Window-Target"
}
variable "target_description" {
  default = "This is a maintenance window target for EC2 patching."
}
variable "target_resource_type" {
  default = "INSTANCE"
}
variable "target_key" {
  default = "ssm-patching"
}
variable "target_values" {
  type = list
  default = ["true"]
}
variable "task_max_concurrency" {
  default = 2
}
variable "task_max_errors" {
  default = 1
}
variable "task_max_priority" {
  default = 1
}
variable "task_arn" {
  default = "EC2-Patching-Automation"
}
variable "task_type" {
  default = "AUTOMATION"
}
variable "task_window_id" {
  default = "aws_ssm_maintenance_window.ec2-patch-window.id"
}
variable "task_target_id" {
  default = "WindowTargetIds"
}
variable "task_target_values" {
  type = list
  default = ["aws_ssm_maintenance_window_target.ec2-patch-target.id"]
}
variable "task_document_version" {
  default = "$DEFAULT"
}
variable "task_parameter_name" {
  default = "InstanceId"
}
variable "task_parameter_values" {
  default = ["{{TARGET_ID}}"]
}
