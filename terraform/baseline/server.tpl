[
  {
    "name": "ws-container",
    "image": "image/tag",
    "repositoryCredentials": {
        "credentialsParameter": ""
      },
    "memory": 512,
    "memoryReservation": 512,
    "cpu": 256,
    "portMappings": [
      {
        "containerPort": 5000,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "API_KEY",
        "value": "${api_key}"
      },
      {
        "name": "UUID",
        "value": "${uuid}"
      },
      {
        "name": "MONGO_URI",
        "value": ""
      },
      {
        "name": "PRODUCT",
        "value": ""
      },
      {
        "name": "SIGNING_SECRET",
        "value": ""
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ws"
      }
    }
  }
]
