## Container Orchestration Integration


### Kubernetes Infrastructure

```hcl
# kubernetes-infrastructure.tf
# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version
  
  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = var.public_access_enabled
    public_access_cidrs    = var.public_access_cidrs
  }
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# Node Groups
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id
  
  capacity_type  = "ON_DEMAND"
  instance_types = var.node_instance_types
  
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }
  
  update_config {
    max_unavailable_percentage = 25
  }
  
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]
}

# Fargate Profile
resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.environment}-fargate"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids            = aws_subnet.private[*].id
  
  selector {
    namespace = "fargate"
  }
  
  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }
}

# IRSA (IAM Roles for Service Accounts)
module "irsa_aws_load_balancer_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  
  role_name = "${var.environment}-aws-load-balancer-controller"
  
  attach_load_balancer_controller_policy = true
  
  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}
```

### Kubernetes Resources via Terraform

```hcl
# kubernetes-resources.tf
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name]
    }
  }
}

# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.1"
  
  values = [
    yamlencode({
      clusterName = aws_eks_cluster.main.name
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa_aws_load_balancer_controller.iam_role_arn
        }
      }
    })
  ]
  
  depends_on = [aws_eks_node_group.main]
}

# Ingress Controller
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  
  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]
}

# Application Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }
  
  spec {
    replicas = var.app_replicas
    
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      
      spec {
        container {
          image = "${var.app_image}:${var.app_version}"
          name  = var.app_name
          
          port {
            container_port = var.app_port
          }
          
          env {
            name  = "DATABASE_URL"
            value = aws_db_instance.main.endpoint
          }
          
          env {
            name = "REDIS_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app_secrets.metadata[0].name
                key  = "redis-url"
              }
            }
          }
          
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = var.app_port
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}
```

### Docker Swarm Integration

```hcl
# docker-swarm.tf
resource "aws_instance" "swarm_manager" {
  count         = var.manager_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.manager_instance_type
  key_name      = aws_key_pair.main.key_name
  
  vpc_security_group_ids = [aws_security_group.swarm_manager.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/swarm_manager.sh", {
    is_primary = count.index == 0
    join_token_command = count.index == 0 ? "" : data.external.swarm_tokens.result.manager_token
  })
  
  tags = {
    Name = "${var.environment}-swarm-manager-${count.index + 1}"
    Role = "swarm-manager"
  }
}

resource "aws_instance" "swarm_worker" {
  count         = var.worker_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type
  key_name      = aws_key_pair.main.key_name
  
  vpc_security_group_ids = [aws_security_group.swarm_worker.id]
  subnet_id             = aws_subnet.private[count.index % length(aws_subnet.private)].id
  
  user_data = templatefile("${path.module}/templates/swarm_worker.sh", {
    manager_ip = aws_instance.swarm_manager[0].private_ip
    join_token = data.external.swarm_tokens.result.worker_token
  })
  
  tags = {
    Name = "${var.environment}-swarm-worker-${count.index + 1}"
    Role = "swarm-worker"
  }
  
  depends_on = [aws_instance.swarm_manager]
}

# Get Swarm join tokens
data "external" "swarm_tokens" {
  program = ["bash", "${path.module}/scripts/get_swarm_tokens.sh"]
  
  query = {
    manager_ip = aws_instance.swarm_manager[0].private_ip
    key_file   = aws_key_pair.main.key_name
  }
  
  depends_on = [aws_instance.swarm_manager]
}

# Deploy stack via Docker Compose
resource "null_resource" "deploy_stack" {
  triggers = {
    compose_file_hash = filemd5("${path.module}/docker-compose.yml")
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      docker -H ssh://ubuntu@${aws_instance.swarm_manager[0].public_ip} \
        stack deploy -c ${path.module}/docker-compose.yml ${var.stack_name}
    EOT
  }
  
  depends_on = [aws_instance.swarm_worker]
}
```

