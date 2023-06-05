resource "aws_ssm_document" "ec2-patch-document" {
  name          = var.document_name
  document_format = var.document_format
  document_type = var.document_type

  content = var.document_file
}

resource "aws_ssm_maintenance_window" "ec2-patch-window" {
  name     = var.window_name
  schedule = var.cron_schedule
  duration = var.window_duration
  cutoff   = var.window_cutoff
}

resource "aws_ssm_maintenance_window_target" "ec2-patch-target" {
  window_id     = var.target_id
  name          = var.target_name
  description   = var.target_description
  resource_type = var.target_resource_type

  targets {
    key    = var.target_key
    values = var.target_values
  }
}

resource "aws_ssm_maintenance_window_task" "ec2-patch-task" {
  max_concurrency = var.task_max_concurrency
  max_errors      = var.task_max_errors
  priority        = var.task_max_priority
  task_arn        = var.task_arn
  task_type       = var.task_type
  window_id       = var.task_window_id

  targets {
    key    = var.task_target_id
    values = var.task_target_values
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = var.task_document_version

      parameter {
        name   = var.task_parameter_name
        values = var.task_parameter_values
      }
    }
  }
}
