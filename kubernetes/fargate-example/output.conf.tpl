[OUTPUT]
    Name              cloudwatch_logs
    Match             *
    region            ${aws_region}
    log_group_name    ${fargate_logging_name}
    log_stream_prefix fb-
    auto_create_group true