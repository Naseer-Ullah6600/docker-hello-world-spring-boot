# CI/CD Pipeline Setup Guide

This guide will help you set up the complete CI/CD pipeline for deploying your Spring Boot application to EKS via ECR.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **EKS Cluster** running
3. **ECR Repository** created
4. **GitHub Repository** with your code

## Step 1: Create ECR Repository

```bash
aws ecr create-repository \
    --repository-name hello-world-spring-boot \
    --region us-east-1
```

## Step 2: Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

## Step 3: Update Configuration

### Update GitHub Actions Workflow

Edit `.github/workflows/deploy.yml` and update:

```yaml
env:
  AWS_REGION: your-aws-region  # e.g., us-east-1
  ECR_REPOSITORY: hello-world-spring-boot
  EKS_CLUSTER_NAME: your-eks-cluster-name
  EKS_NAMESPACE: zad-demo-app  # or your preferred namespace
```

### Update Kubernetes Manifests

Edit `k8s/deployment.yaml` and update:

```yaml
# Replace 'your-domain.com' with your actual domain
host: your-domain.com
```

## Step 4: Initial EKS Setup

1. **Apply namespace and initial resources:**

```bash
# Make sure you have kubectl configured for your EKS cluster
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
```

2. **Or use the provided script:**

```bash
chmod +x k8s/apply-resources.sh
./k8s/apply-resources.sh
```

## Step 5: Configure AWS IAM Permissions

Ensure your AWS user has the following permissions:

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
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
```

## Step 6: Test the Pipeline

1. **Push to main branch** - This will trigger the pipeline
2. **Monitor the workflow** in GitHub Actions
3. **Check ECR** for your new image
4. **Verify deployment** in your EKS cluster

## Pipeline Features

- ✅ **Multi-stage Docker build** for optimized images
- ✅ **Random tagging** (timestamp + commit SHA) instead of 'latest'
- ✅ **Health checks** with Spring Boot Actuator
- ✅ **Automatic EKS deployment** with rollout verification
- ✅ **Maven caching** for faster builds
- ✅ **Comprehensive testing** before deployment

## Troubleshooting

### Common Issues

1. **ECR Login Failed**
   - Check AWS credentials in GitHub secrets
   - Verify ECR repository exists

2. **EKS Deployment Failed**
   - Ensure kubectl is configured for your cluster
   - Check if the deployment exists in the namespace

3. **Image Pull Errors**
   - Verify ECR repository permissions
   - Check image tag in deployment

### Useful Commands

```bash
# Check ECR images
aws ecr describe-images --repository-name hello-world-spring-boot

# Check EKS pods
kubectl get pods -n zad-demo-app

# Check deployment status
kubectl rollout status deployment/hello-world-app -n zad-demo-app

# View logs
kubectl logs -f deployment/hello-world-app -n zad-demo-app
```

## Security Considerations

- Use IAM roles instead of access keys when possible
- Implement proper RBAC in Kubernetes
- Consider using ECR scanning for vulnerabilities
- Use private subnets for EKS worker nodes

## Cost Optimization

- Use spot instances for EKS worker nodes
- Implement proper resource limits
- Use ECR lifecycle policies to clean up old images
- Consider using ECR Public for public images
