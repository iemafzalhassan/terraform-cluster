# EKS Auto Mode Cluster - Terraform Configuration

A production-ready Amazon EKS cluster with Auto Mode (Karpenter) for dynamic scaling. Perfect for learning Kubernetes, demos, and development workloads.

## 🎯 What This Creates

- **EKS Cluster** (Kubernetes 1.31) with Auto Mode enabled
- **VPC** with public/private subnets across 3 availability zones
- **Security Groups** configured for secure access
- **Auto-scaling** via Karpenter (nodes scale automatically)
- **Essential Add-ons**: EBS CSI Driver, Load Balancer Controller, Metrics Server
- **Security**: KMS encryption, IRSA, CloudWatch logging

## 📋 Prerequisites

Before you begin, ensure you have:

- **AWS CLI** configured with credentials (`aws configure`)
- **Terraform** >= 1.5.0 (`terraform version`)
- **kubectl** >= 1.31 (`kubectl version`)
- **AWS Account** with permissions to create EKS, VPC, EC2, IAM resources

Verify your setup:
```bash
aws sts get-caller-identity  # Should show your AWS account
terraform version            # Should be >= 1.5.0
kubectl version --client    # Should be >= 1.31
```

## 🚀 Quick Start

### Step 1: Get Your IP Address

```bash
curl -4 ifconfig.me
```

**Example output:** `182.48.223.179`

### Step 2: Update Configuration

Edit `terraform.tfvars` and update line 6 with your IP:

```hcl
my_home_ip = "182.48.223.179/32"  # 👈 Replace with YOUR IP!
```

### Step 3: Deploy the Cluster

```bash
# Initialize Terraform (downloads providers)
terraform init

# Review what will be created (always do this first!)
terraform plan

# Deploy the cluster (takes ~15-20 minutes)
terraform apply
```

Type `yes` when prompted.

### Step 4: Connect to Your Cluster

```bash
aws eks update-kubeconfig \
  --region eu-west-1 \
  --name afzal-demo-eks
```

### Step 5: Verify Everything Works

```bash
# Check nodes are running
kubectl get nodes

# Check all pods
kubectl get pods -A

# Check resource usage
kubectl top nodes
```

## 📁 Project Structure

```
eks-auto-mode-terraform/
├── README.md                    # This file - your guide
├── terraform.tfvars            # 👈 EDIT THIS: Your IP and settings
├── variables.tf                # Variable definitions (defaults)
├── main.tf                     # Main orchestration (calls modules)
├── outputs.tf                  # Cluster information outputs
├── versions.tf                 # Provider versions
│
├── modules/
│   ├── vpc/                    # Creates VPC, subnets, NAT gateway
│   ├── eks/                     # Creates EKS cluster and add-ons
│   └── security-groups/         # Creates security rules
│
└── scripts/
    ├── connect.sh              # Connect to cluster
    ├── update-ip.sh            # Update your IP when it changes
    └── install-addons.sh       # Install optional add-ons
```

## 🔄 Common Operations

### When Your IP Changes

If your router restarts or you change networks:

```bash
# Update terraform.tfvars, then:
terraform apply -target=module.security_groups
```

### Deploy a Test Application

```bash
# Simple NGINX deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get the LoadBalancer URL
kubectl get svc nginx
```


### View Cluster Information

```bash
# Get cluster details
terraform output

# Get connection command
terraform output configure_kubectl
```

## 🗑️ Cleanup (Important!)

**Always destroy the cluster when done to avoid charges:**

```bash
# Delete all Kubernetes resources first
kubectl delete all --all -A

# Destroy infrastructure
terraform destroy
```

Type `yes` when prompted.

**Estimated cost:** ~$0.23/hour (~$170/month if running 24/7)

### How It Works

1. **VPC Module** creates network (VPC, subnets, NAT gateway)
2. **EKS Module** creates Kubernetes cluster in the VPC
3. **Security Groups Module** creates firewall rules
4. **Helm Resources** deploy add-ons to the cluster

Everything is connected via module outputs (e.g., `module.vpc.vpc_id`).

## 🎓 Learning Resources

- **EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Karpenter Guide**: https://karpenter.sh/docs/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws
- **Kubernetes Basics**: https://kubernetes.io/docs/tutorials/

## 📞 Getting Help

1. **Check error messages** - They usually tell you what's wrong
2. **Review AWS Console** - See what resources were created
3. **Check Terraform state**: `terraform show`
4. **View logs**: `kubectl logs -n <namespace> <pod-name>`

---

**Remember:** Always run `terraform destroy` when done to save money! 💰

**Built for learning and demos** 🎓
