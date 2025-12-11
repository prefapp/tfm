# ============================================================================
# AUTOSCALING TARGETS
# ============================================================================

resource "aws_appautoscaling_target" "ecs" {
  for_each = {
    for k, v in var.ecs_autoscaling : k => v
    if v.autoscaling_enabled
  }

  depends_on = [aws_ecs_service.this]

  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ============================================================================
# SCALING POLICIES
# ============================================================================

resource "aws_appautoscaling_policy" "scale_up" {
  for_each = aws_appautoscaling_target.ecs

  name               = "${each.key}-scale-up"
  policy_type        = "StepScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.ecs_autoscaling[each.key].scale.up.adjustment_type
    cooldown                = var.ecs_autoscaling[each.key].scale.up.cooldown
    metric_aggregation_type = try(var.ecs_autoscaling[each.key].custom_metric.metric_aggregation_type, "Average")

    step_adjustment {
      metric_interval_upper_bound = var.ecs_autoscaling[each.key].scale.up.threshold
      scaling_adjustment          = var.ecs_autoscaling[each.key].scale.up.scaling_adjustment
    }
    step_adjustment {
      metric_interval_lower_bound = var.ecs_autoscaling[each.key].scale.up.threshold
      scaling_adjustment          = var.ecs_autoscaling[each.key].scale.up.scaling_adjustment
    }
  }
}


resource "aws_appautoscaling_policy" "scale_down" {
  for_each = aws_appautoscaling_target.ecs

  name               = "${each.key}-scale-down"
  policy_type        = "StepScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = var.ecs_autoscaling[each.key].scale.down.adjustment_type
    cooldown                = var.ecs_autoscaling[each.key].scale.down.cooldown
    metric_aggregation_type = try(var.ecs_autoscaling[each.key].custom_metric.metric_aggregation_type, "Average")

    step_adjustment {
      metric_interval_upper_bound = var.ecs_autoscaling[each.key].scale.down.threshold
      scaling_adjustment          = var.ecs_autoscaling[each.key].scale.down.scaling_adjustment
    }
    step_adjustment {
      metric_interval_lower_bound = var.ecs_autoscaling[each.key].scale.down.threshold
      scaling_adjustment          = var.ecs_autoscaling[each.key].scale.down.scaling_adjustment
    }
  }
}


# ============================================================================
# CLOUDWATCH ALARMS
# ============================================================================
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  for_each = aws_appautoscaling_target.ecs

  alarm_name          = "${each.key}-scale-up"
  comparison_operator = var.ecs_autoscaling[each.key].scale.up.comparison_operator
  evaluation_periods  = var.ecs_autoscaling[each.key].scale.up.evaluation_periods
  threshold           = var.ecs_autoscaling[each.key].scale.up.threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_up[each.key].arn]
  treat_missing_data  = try(var.ecs_autoscaling[each.key].custom_metric.treat_missing_data, "missing")
  datapoints_to_alarm = try(var.ecs_autoscaling[each.key].custom_metric.datapoints_to_alarm, 1)

  dynamic "metric_query" {
    for_each = var.ecs_autoscaling[each.key].metric_type == "custom" ? [1] : []
    content {
      id          = "m1"
      return_data = true
      metric {
        metric_name = var.ecs_autoscaling[each.key].custom_metric.name
        namespace   = var.ecs_autoscaling[each.key].custom_metric.namespace
        period      = var.ecs_autoscaling[each.key].scale.up.period
        stat        = var.ecs_autoscaling[each.key].metric_statistic
        dimensions  = var.ecs_autoscaling[each.key].custom_metric.dimensions
      }
    }
  }

  dynamic "metric_query" {
    for_each = var.ecs_autoscaling[each.key].metric_type != "custom" ? [1] : []
    content {
      id          = "m1"
      return_data = true
      metric {
        metric_name = var.ecs_autoscaling[each.key].metric_type == "cpu" ? "CPUUtilization" : "MemoryUtilization"
        namespace   = "AWS/ECS"
        period      = var.ecs_autoscaling[each.key].scale.up.period
        stat        = var.ecs_autoscaling[each.key].metric_statistic
        dimensions = {
          ClusterName = aws_ecs_cluster.this.name
          ServiceName = each.key
        }
      }
    }
  }
}


resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  for_each = aws_appautoscaling_target.ecs

  alarm_name          = "${each.key}-scale-down"
  comparison_operator = var.ecs_autoscaling[each.key].scale.down.comparison_operator
  evaluation_periods  = var.ecs_autoscaling[each.key].scale.down.evaluation_periods
  threshold           = var.ecs_autoscaling[each.key].scale.down.threshold
  alarm_actions       = [aws_appautoscaling_policy.scale_down[each.key].arn]
  treat_missing_data  = try(var.ecs_autoscaling[each.key].custom_metric.treat_missing_data, "missing")
  datapoints_to_alarm = try(var.ecs_autoscaling[each.key].custom_metric.datapoints_to_alarm, 1)

  dynamic "metric_query" {
    for_each = var.ecs_autoscaling[each.key].metric_type == "custom" ? [1] : []
    content {
      id          = "m1"
      return_data = true
      metric {
        metric_name = var.ecs_autoscaling[each.key].custom_metric.name
        namespace   = var.ecs_autoscaling[each.key].custom_metric.namespace
        period      = var.ecs_autoscaling[each.key].scale.down.period
        stat        = var.ecs_autoscaling[each.key].metric_statistic
        dimensions  = var.ecs_autoscaling[each.key].custom_metric.dimensions
      }
    }
  }

  dynamic "metric_query" {
    for_each = var.ecs_autoscaling[each.key].metric_type != "custom" ? [1] : []
    content {
      id          = "m1"
      return_data = true
      metric {
        metric_name = var.ecs_autoscaling[each.key].metric_type == "cpu" ? "CPUUtilization" : "MemoryUtilization"
        namespace   = "AWS/ECS"
        period      = var.ecs_autoscaling[each.key].scale.down.period
        stat        = var.ecs_autoscaling[each.key].metric_statistic
        dimensions = {
          ClusterName = aws_ecs_cluster.this.name
          ServiceName = each.key
        }
      }
    }
  }
}
