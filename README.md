# ECR Node.js Application

A Node.js application containerized with Docker and deployed to AWS ECS via GitHub Actions.

## Prerequisites

1. AWS Account with:
   - ECR repository created
   - ECS cluster and service configured
   - Task definition created
   - IAM roles with proper permissions

2. GitHub Secrets configured:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

## AWS Setup

### 1. Create ECR Repository
```bash
aws ecs create-repository --repository-name ecr-nodejs-app --region us-east-1
```

### 2. Create ECS Cluster
```bash
aws ecs create-cluster --cluster-name ecr-cluster --region us-east-1
```

### 3. Register Task Definition
```bash
aws ecs register-task-definition --cli-input-json file://task-definition.json --region us-east-1
```

Note: Update the `task-definition.json` file with:
- Your AWS account ID
- IAM role ARNs
- ECR repository URI

### 4. Create ECS Service
```bash
aws ecs create-service \
  --cluster ecr-cluster \
  --service-name ecr-nodejs-service \
  --task-definition ecr-nodejs-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}" \
  --region us-east-1
```

### 5. IAM Roles Required

- **ECS Task Execution Role**: Allows ECS to pull images from ECR and write logs
- **ECS Task Role**: Permissions for the running container (if needed)

Example policy for Task Execution Role:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

## GitHub Actions Setup

1. Go to your repository Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

## Configuration

Update the following in `.github/workflows/deploy.yml`:
- `AWS_REGION`: Your AWS region
- `ECR_REPOSITORY`: Your ECR repository name
- `ECS_SERVICE`: Your ECS service name
- `ECS_CLUSTER`: Your ECS cluster name
- `ECS_TASK_DEFINITION`: Your task definition family name

## Usage

The pipeline will automatically trigger on:
- Push to `main` or `master` branch
- Manual trigger via GitHub Actions UI

The workflow will:
1. Build the Docker image
2. Push to ECR
3. Update the ECS task definition with the new image
4. Deploy to ECS service

## Local Development

### Build Docker image
```bash
docker build -t ecr-nodejs-app .
```

### Run locally
```bash
docker run -p 3000:3000 ecr-nodejs-app
```

Visit `http://localhost:3000` to see the application.

