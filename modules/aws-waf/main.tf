resource "aws_wafv2_ip_set" "this" {
  for_each = var.ip_sets

  name               = "${var.name}-${each.key}"
  description        = each.value.description
  scope              = var.scope
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })
}

resource "aws_wafv2_regex_pattern_set" "this" {
  for_each = var.regex_pattern_sets

  name        = "${var.name}-${each.key}"
  description = each.value.description
  scope       = var.scope

  dynamic "regular_expression" {
    for_each = each.value.patterns
    content {
      regex_string = regular_expression.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
  })
}

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "custom_response_body" {
    for_each = var.custom_response_bodies
    content {
      key          = custom_response_body.key
      content      = custom_response_body.value.content
      content_type = custom_response_body.value.content_type
    }
  }

  token_domains = length(var.token_domains) > 0 ? var.token_domains : null

  dynamic "captcha_config" {
    for_each = var.captcha_config != null ? [var.captcha_config] : []
    content {
      dynamic "immunity_time_property" {
        for_each = captcha_config.value.immunity_time_property != null ? [captcha_config.value.immunity_time_property] : []
        content {
          immunity_time = immunity_time_property.value.immunity_time
        }
      }
    }
  }

  dynamic "challenge_config" {
    for_each = var.challenge_config != null ? [var.challenge_config] : []
    content {
      dynamic "immunity_time_property" {
        for_each = challenge_config.value.immunity_time_property != null ? [challenge_config.value.immunity_time_property] : []
        content {
          immunity_time = immunity_time_property.value.immunity_time
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.aws_managed_rules
    content {
      name     = "${rule.value.vendor_name}-${rule.value.name}"
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = rule.value.vendor_name
          version     = rule.value.version

          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_overrides
            content {
              name = rule_action_override.key
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value == "block" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value == "count" ? [1] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule_action_override.value == "captcha" ? [1] : []
                  content {}
                }
                dynamic "challenge" {
                  for_each = rule_action_override.value == "challenge" ? [1] : []
                  content {}
                }
              }
            }
          }

          dynamic "scope_down_statement" {
            for_each = rule.value.scope_down_statement != null ? [rule.value.scope_down_statement] : []
            content {
              dynamic "geo_match_statement" {
                for_each = try(scope_down_statement.value.geo_match, null) != null ? [scope_down_statement.value.geo_match] : []
                content {
                  country_codes = geo_match_statement.value.country_codes
                }
              }

              dynamic "ip_set_reference_statement" {
                for_each = try(scope_down_statement.value.ip_set_reference, null) != null ? [scope_down_statement.value.ip_set_reference] : []
                content {
                  arn = try(ip_set_reference_statement.value.ip_set_arn, local.ip_set_arns[ip_set_reference_statement.value.ip_set_key])
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = replace("${rule.value.vendor_name}-${rule.value.name}", "-", "")
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.rule_group_references
    content {
      name     = "rule-group-${rule.key}"
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        rule_group_reference_statement {
          arn = rule.value.arn

          dynamic "rule_action_override" {
            for_each = rule.value.rule_action_overrides
            content {
              name = rule_action_override.key
              action_to_use {
                dynamic "allow" {
                  for_each = rule_action_override.value == "allow" ? [1] : []
                  content {}
                }
                dynamic "block" {
                  for_each = rule_action_override.value == "block" ? [1] : []
                  content {}
                }
                dynamic "count" {
                  for_each = rule_action_override.value == "count" ? [1] : []
                  content {}
                }
                dynamic "captcha" {
                  for_each = rule_action_override.value == "captcha" ? [1] : []
                  content {}
                }
                dynamic "challenge" {
                  for_each = rule_action_override.value == "challenge" ? [1] : []
                  content {}
                }
              }
            }
          }

        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RuleGroup${rule.key}"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = { for idx, rule in var.custom_rules : rule.name => rule }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }

        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {
            dynamic "custom_response" {
              for_each = try(rule.value.action_block_custom_response, null) != null ? [rule.value.action_block_custom_response] : []
              content {
                response_code            = custom_response.value.response_code
                custom_response_body_key = try(custom_response.value.custom_response_body_key, null)

                dynamic "response_header" {
                  for_each = try(custom_response.value.response_headers, [])
                  content {
                    name  = response_header.value.name
                    value = response_header.value.value
                  }
                }
              }
            }
          }
        }

        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }

        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }

        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
      }

      dynamic "rule_label" {
        for_each = try(rule.value.rule_labels, [])
        content {
          name = rule_label.value
        }
      }

      statement {
        dynamic "ip_set_reference_statement" {
          for_each = try(rule.value.statement.ip_set_reference, null) != null ? [rule.value.statement.ip_set_reference] : []
          content {
            arn = try(
              ip_set_reference_statement.value.ip_set_arn,
              local.ip_set_arns[ip_set_reference_statement.value.ip_set_key]
            )

            dynamic "ip_set_forwarded_ip_config" {
              for_each = try(ip_set_reference_statement.value.ip_set_forwarded_ip_config, null) != null ? [ip_set_reference_statement.value.ip_set_forwarded_ip_config] : []
              content {
                header_name       = ip_set_forwarded_ip_config.value.header_name
                fallback_behavior = ip_set_forwarded_ip_config.value.fallback_behavior
                position          = ip_set_forwarded_ip_config.value.position
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = try(rule.value.statement.geo_match, null) != null ? [rule.value.statement.geo_match] : []
          content {
            country_codes = geo_match_statement.value.country_codes

            dynamic "forwarded_ip_config" {
              for_each = try(geo_match_statement.value.forwarded_ip_config, null) != null ? [geo_match_statement.value.forwarded_ip_config] : []
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }
          }
        }

        dynamic "rate_based_statement" {
          for_each = try(rule.value.statement.rate_based, null) != null ? [rule.value.statement.rate_based] : []
          content {
            limit                 = rate_based_statement.value.limit
            aggregate_key_type    = try(rate_based_statement.value.aggregate_key_type, "IP")
            evaluation_window_sec = try(rate_based_statement.value.evaluation_window_sec, 300)

            dynamic "forwarded_ip_config" {
              for_each = try(rate_based_statement.value.forwarded_ip_config, null) != null ? [rate_based_statement.value.forwarded_ip_config] : []
              content {
                header_name       = forwarded_ip_config.value.header_name
                fallback_behavior = forwarded_ip_config.value.fallback_behavior
              }
            }

            dynamic "custom_key" {
              for_each = try(rate_based_statement.value.custom_keys, null) != null ? rate_based_statement.value.custom_keys : []
              content {
                dynamic "cookie" {
                  for_each = try(custom_key.value.cookie, null) != null ? [custom_key.value.cookie] : []
                  content {
                    name = cookie.value.name
                    dynamic "text_transformation" {
                      for_each = cookie.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }

                dynamic "header" {
                  for_each = try(custom_key.value.header, null) != null ? [custom_key.value.header] : []
                  content {
                    name = header.value.name
                    dynamic "text_transformation" {
                      for_each = header.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }

                dynamic "query_string" {
                  for_each = try(custom_key.value.query_string, null) != null ? [custom_key.value.query_string] : []
                  content {
                    dynamic "text_transformation" {
                      for_each = query_string.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }

                dynamic "ip" {
                  for_each = try(custom_key.value.ip, null) != null ? [custom_key.value.ip] : []
                  content {}
                }

                dynamic "forwarded_ip" {
                  for_each = try(custom_key.value.forwarded_ip, null) != null ? [custom_key.value.forwarded_ip] : []
                  content {}
                }
              }
            }

            dynamic "scope_down_statement" {
              for_each = try(rate_based_statement.value.scope_down_statement, null) != null ? [rate_based_statement.value.scope_down_statement] : []
              content {
                dynamic "geo_match_statement" {
                  for_each = try(scope_down_statement.value.geo_match, null) != null ? [scope_down_statement.value.geo_match] : []
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }

                dynamic "ip_set_reference_statement" {
                  for_each = try(scope_down_statement.value.ip_set_reference, null) != null ? [scope_down_statement.value.ip_set_reference] : []
                  content {
                    arn = try(
                      ip_set_reference_statement.value.ip_set_arn,
                      local.ip_set_arns[ip_set_reference_statement.value.ip_set_key]
                    )
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = try(scope_down_statement.value.byte_match, null) != null ? [scope_down_statement.value.byte_match] : []
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string

                    dynamic "field_to_match" {
                      for_each = [byte_match_statement.value.field_to_match]
                      content {
                        dynamic "uri_path" {
                          for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                          content {}
                        }
                        dynamic "query_string" {
                          for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                          content {
                            name = single_header.value.name
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = byte_match_statement.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "regex_pattern_set_reference_statement" {
          for_each = try(rule.value.statement.regex_pattern_set_reference, null) != null ? [rule.value.statement.regex_pattern_set_reference] : []
          content {
            arn = try(
              regex_pattern_set_reference_statement.value.regex_set_arn,
              local.regex_pattern_set_arns[regex_pattern_set_reference_statement.value.regex_set_key]
            )

            dynamic "field_to_match" {
              for_each = [regex_pattern_set_reference_statement.value.field_to_match]
              content {
                dynamic "body" {
                  for_each = try(field_to_match.value.body, null) != null ? [field_to_match.value.body] : []
                  content {
                    oversize_handling = try(body.value.oversize_handling, "CONTINUE")
                  }
                }
                dynamic "method" {
                  for_each = try(field_to_match.value.method, null) != null ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "single_query_argument" {
                  for_each = try(field_to_match.value.single_query_argument, null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = single_query_argument.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try(field_to_match.value.all_query_arguments, null) != null ? [1] : []
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = regex_pattern_set_reference_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "regex_match_statement" {
          for_each = try(rule.value.statement.regex_match, null) != null ? [rule.value.statement.regex_match] : []
          content {
            regex_string = regex_match_statement.value.regex_string

            dynamic "field_to_match" {
              for_each = [regex_match_statement.value.field_to_match]
              content {
                dynamic "body" {
                  for_each = try(field_to_match.value.body, null) != null ? [field_to_match.value.body] : []
                  content {
                    oversize_handling = try(body.value.oversize_handling, "CONTINUE")
                  }
                }
                dynamic "json_body" {
                  for_each = try(field_to_match.value.json_body, null) != null ? [field_to_match.value.json_body] : []
                  content {
                    match_scope               = json_body.value.match_scope
                    oversize_handling         = try(json_body.value.oversize_handling, "CONTINUE")
                    invalid_fallback_behavior = try(json_body.value.invalid_fallback_behavior, null)

                    dynamic "match_pattern" {
                      for_each = [json_body.value.match_pattern]
                      content {
                        dynamic "all" {
                          for_each = try(match_pattern.value.all, null) != null ? [1] : []
                          content {}
                        }
                        included_paths = try(match_pattern.value.included_paths, null)
                      }
                    }
                  }
                }
                dynamic "method" {
                  for_each = try(field_to_match.value.method, null) != null ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "single_query_argument" {
                  for_each = try(field_to_match.value.single_query_argument, null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = single_query_argument.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try(field_to_match.value.all_query_arguments, null) != null ? [1] : []
                  content {}
                }
                dynamic "cookies" {
                  for_each = try(field_to_match.value.cookies, null) != null ? [field_to_match.value.cookies] : []
                  content {
                    match_scope       = cookies.value.match_scope
                    oversize_handling = try(cookies.value.oversize_handling, "CONTINUE")

                    dynamic "match_pattern" {
                      for_each = [cookies.value.match_pattern]
                      content {
                        dynamic "all" {
                          for_each = try(match_pattern.value.all, null) != null ? [1] : []
                          content {}
                        }
                        included_cookies = try(match_pattern.value.included_cookies, null)
                        excluded_cookies = try(match_pattern.value.excluded_cookies, null)
                      }
                    }
                  }
                }
                dynamic "headers" {
                  for_each = try(field_to_match.value.headers, null) != null ? [field_to_match.value.headers] : []
                  content {
                    match_scope       = headers.value.match_scope
                    oversize_handling = try(headers.value.oversize_handling, "CONTINUE")

                    dynamic "match_pattern" {
                      for_each = [headers.value.match_pattern]
                      content {
                        dynamic "all" {
                          for_each = try(match_pattern.value.all, null) != null ? [1] : []
                          content {}
                        }
                        included_headers = try(match_pattern.value.included_headers, null)
                        excluded_headers = try(match_pattern.value.excluded_headers, null)
                      }
                    }
                  }
                }
              }
            }

            dynamic "text_transformation" {
              for_each = regex_match_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "byte_match_statement" {
          for_each = try(rule.value.statement.byte_match, null) != null ? [rule.value.statement.byte_match] : []
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string

            dynamic "field_to_match" {
              for_each = [byte_match_statement.value.field_to_match]
              content {
                dynamic "body" {
                  for_each = try(field_to_match.value.body, null) != null ? [field_to_match.value.body] : []
                  content {
                    oversize_handling = try(body.value.oversize_handling, "CONTINUE")
                  }
                }
                dynamic "method" {
                  for_each = try(field_to_match.value.method, null) != null ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "single_query_argument" {
                  for_each = try(field_to_match.value.single_query_argument, null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = single_query_argument.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try(field_to_match.value.all_query_arguments, null) != null ? [1] : []
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = byte_match_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "size_constraint_statement" {
          for_each = try(rule.value.statement.size_constraint, null) != null ? [rule.value.statement.size_constraint] : []
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size

            dynamic "field_to_match" {
              for_each = [size_constraint_statement.value.field_to_match]
              content {
                dynamic "body" {
                  for_each = try(field_to_match.value.body, null) != null ? [field_to_match.value.body] : []
                  content {
                    oversize_handling = try(body.value.oversize_handling, "CONTINUE")
                  }
                }
                dynamic "method" {
                  for_each = try(field_to_match.value.method, null) != null ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = single_header.value.name
                  }
                }
                dynamic "single_query_argument" {
                  for_each = try(field_to_match.value.single_query_argument, null) != null ? [field_to_match.value.single_query_argument] : []
                  content {
                    name = single_query_argument.value.name
                  }
                }
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
                dynamic "all_query_arguments" {
                  for_each = try(field_to_match.value.all_query_arguments, null) != null ? [1] : []
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = size_constraint_statement.value.text_transformation
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "label_match_statement" {
          for_each = try(rule.value.statement.label_match, null) != null ? [rule.value.statement.label_match] : []
          content {
            scope = label_match_statement.value.scope
            key   = label_match_statement.value.key
          }
        }

        dynamic "not_statement" {
          for_each = try(rule.value.statement.not, null) != null ? [rule.value.statement.not] : []
          content {
            statement {
              dynamic "ip_set_reference_statement" {
                for_each = try(not_statement.value.ip_set_reference, null) != null ? [not_statement.value.ip_set_reference] : []
                content {
                  arn = try(
                    ip_set_reference_statement.value.ip_set_arn,
                    local.ip_set_arns[ip_set_reference_statement.value.ip_set_key]
                  )
                }
              }

              dynamic "geo_match_statement" {
                for_each = try(not_statement.value.geo_match, null) != null ? [not_statement.value.geo_match] : []
                content {
                  country_codes = geo_match_statement.value.country_codes
                }
              }

              dynamic "byte_match_statement" {
                for_each = try(not_statement.value.byte_match, null) != null ? [not_statement.value.byte_match] : []
                content {
                  positional_constraint = byte_match_statement.value.positional_constraint
                  search_string         = byte_match_statement.value.search_string

                  dynamic "field_to_match" {
                    for_each = [byte_match_statement.value.field_to_match]
                    content {
                      dynamic "uri_path" {
                        for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                        content {}
                      }
                      dynamic "single_header" {
                        for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                        content {
                          name = single_header.value.name
                        }
                      }
                    }
                  }

                  dynamic "text_transformation" {
                    for_each = byte_match_statement.value.text_transformation
                    content {
                      priority = text_transformation.value.priority
                      type     = text_transformation.value.type
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "and_statement" {
          for_each = try(rule.value.statement.and, null) != null ? [rule.value.statement.and] : []
          content {
            dynamic "statement" {
              for_each = and_statement.value.statements
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = try(statement.value.ip_set_reference, null) != null ? [statement.value.ip_set_reference] : []
                  content {
                    arn = try(
                      ip_set_reference_statement.value.ip_set_arn,
                      local.ip_set_arns[ip_set_reference_statement.value.ip_set_key]
                    )
                  }
                }

                dynamic "geo_match_statement" {
                  for_each = try(statement.value.geo_match, null) != null ? [statement.value.geo_match] : []
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string

                    dynamic "field_to_match" {
                      for_each = [byte_match_statement.value.field_to_match]
                      content {
                        dynamic "uri_path" {
                          for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                          content {
                            name = single_header.value.name
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = byte_match_statement.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = try(statement.value.label_match, null) != null ? [statement.value.label_match] : []
                  content {
                    scope = label_match_statement.value.scope
                    key   = label_match_statement.value.key
                  }
                }
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = try(rule.value.statement.or, null) != null ? [rule.value.statement.or] : []
          content {
            dynamic "statement" {
              for_each = or_statement.value.statements
              content {
                dynamic "ip_set_reference_statement" {
                  for_each = try(statement.value.ip_set_reference, null) != null ? [statement.value.ip_set_reference] : []
                  content {
                    arn = try(
                      ip_set_reference_statement.value.ip_set_arn,
                      local.ip_set_arns[ip_set_reference_statement.value.ip_set_key]
                    )
                  }
                }

                dynamic "geo_match_statement" {
                  for_each = try(statement.value.geo_match, null) != null ? [statement.value.geo_match] : []
                  content {
                    country_codes = geo_match_statement.value.country_codes
                  }
                }

                dynamic "byte_match_statement" {
                  for_each = try(statement.value.byte_match, null) != null ? [statement.value.byte_match] : []
                  content {
                    positional_constraint = byte_match_statement.value.positional_constraint
                    search_string         = byte_match_statement.value.search_string

                    dynamic "field_to_match" {
                      for_each = [byte_match_statement.value.field_to_match]
                      content {
                        dynamic "uri_path" {
                          for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                          content {}
                        }
                        dynamic "single_header" {
                          for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                          content {
                            name = single_header.value.name
                          }
                        }
                      }
                    }

                    dynamic "text_transformation" {
                      for_each = byte_match_statement.value.text_transformation
                      content {
                        priority = text_transformation.value.priority
                        type     = text_transformation.value.type
                      }
                    }
                  }
                }

                dynamic "label_match_statement" {
                  for_each = try(statement.value.label_match, null) != null ? [statement.value.label_match] : []
                  content {
                    scope = label_match_statement.value.scope
                    key   = label_match_statement.value.key
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = try(rule.value.visibility_config.cloudwatch_metrics_enabled, true)
        metric_name                = try(rule.value.visibility_config.metric_name, replace(rule.value.name, "-", ""))
        sampled_requests_enabled   = try(rule.value.visibility_config.sampled_requests_enabled, true)
      }

      dynamic "captcha_config" {
        for_each = try(rule.value.captcha_config, null) != null ? [rule.value.captcha_config] : []
        content {
          dynamic "immunity_time_property" {
            for_each = try(captcha_config.value.immunity_time_property, null) != null ? [captcha_config.value.immunity_time_property] : []
            content {
              immunity_time = immunity_time_property.value.immunity_time
            }
          }
        }
      }

      dynamic "challenge_config" {
        for_each = try(rule.value.challenge_config, null) != null ? [rule.value.challenge_config] : []
        content {
          dynamic "immunity_time_property" {
            for_each = try(challenge_config.value.immunity_time_property, null) != null ? [challenge_config.value.immunity_time_property] : []
            content {
              immunity_time = immunity_time_property.value.immunity_time
            }
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    metric_name                = local.metric_name
    sampled_requests_enabled   = var.sampled_requests_enabled
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_wafv2_web_acl_association" "this" {
  for_each = toset(var.association_resource_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_cloudwatch_log_group" "waf" {
  count = local.create_cloudwatch_log_group ? 1 : 0

  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.logging_configuration.cloudwatch_log_group_retention_days

  tags = merge(var.tags, {
    Name = "aws-waf-logs-${var.name}"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.logging_configuration != null ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = local.log_destination_configs

  dynamic "redacted_fields" {
    for_each = var.logging_configuration.redacted_fields
    content {
      dynamic "method" {
        for_each = redacted_fields.value.method != null ? [1] : []
        content {}
      }
      dynamic "query_string" {
        for_each = redacted_fields.value.query_string != null ? [1] : []
        content {}
      }
      dynamic "single_header" {
        for_each = redacted_fields.value.single_header != null ? [redacted_fields.value.single_header] : []
        content {
          name = single_header.value.name
        }
      }
      dynamic "uri_path" {
        for_each = redacted_fields.value.uri_path != null ? [1] : []
        content {}
      }
    }
  }

  dynamic "logging_filter" {
    for_each = var.logging_configuration.logging_filter != null ? [var.logging_configuration.logging_filter] : []
    content {
      default_behavior = logging_filter.value.default_behavior

      dynamic "filter" {
        for_each = logging_filter.value.filters
        content {
          behavior    = filter.value.behavior
          requirement = filter.value.requirement

          dynamic "condition" {
            for_each = filter.value.conditions
            content {
              dynamic "action_condition" {
                for_each = condition.value.action_condition != null ? [condition.value.action_condition] : []
                content {
                  action = action_condition.value.action
                }
              }
              dynamic "label_name_condition" {
                for_each = condition.value.label_name_condition != null ? [condition.value.label_name_condition] : []
                content {
                  label_name = label_name_condition.value.label_name
                }
              }
            }
          }
        }
      }
    }
  }
}
