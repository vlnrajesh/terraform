[
	{
    "name"        : "${container_name}",
    "image"       : "${container_image}",
    "cpu"         : ${cpu},
    "memory"      : ${memory},
    "essential"   : true,
    "command"     : [
      "-Dsonar.es.bootstrap.checks.disable=true",
      "-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmap=false"
    ],
    "environment": [
       { "name" : "SONAR_JDBC_USERNAME", "value" : "${sq_db_username}" },
       { "name" : "SONAR_JDBC_URL", "value": "${sq_db_url}" }
    ],
    "mountPoints": [
      {
        "containerPath" : "${plugins_home}",
        "sourceVolume"  : "efs-volume"
      }
    ],
    "portMappings": [
        { "protocol": "tcp",
          "containerPort": ${sq_app_port}
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "Options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "sonarqube"
      }
    },
    "secrets" : [
      { "name": "SONAR_JDBC_PASSWORD",
      "valueFrom": "${sq_password_arn}" }
    ]
	}
]