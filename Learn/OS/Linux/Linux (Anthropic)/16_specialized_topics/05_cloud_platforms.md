## Cloud Platforms


### AWS Basics

Amazon Web Services (AWS) is a comprehensive cloud computing platform offering over 200 services across compute, storage, networking, databases, analytics, and machine learning. AWS operates on a global infrastructure with regions, availability zones, and edge locations.

**Core Infrastructure Components:**

AWS regions are geographic areas containing multiple availability zones (AZs). Each AZ represents one or more discrete data centers with redundant power, networking, and connectivity. Edge locations serve CloudFront content delivery network and other services.

**Key Points:**

- AWS operates in 30+ regions with 90+ availability zones globally
- Each region is completely independent for data sovereignty and compliance
- Availability zones within a region are connected via low-latency links
- Edge locations number over 400 worldwide for content delivery

**Compute Services:**

**Amazon EC2 (Elastic Compute Cloud):** Provides resizable compute capacity with various instance types optimized for different workloads:

```bash
# Launch EC2 instance using AWS CLI
aws ec2 run-instances \
    --image-id ami-0abcdef1234567890 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e
```

Instance families include:

- **General Purpose**: t3, t4g, m5, m6i for balanced compute, memory, and networking
- **Compute Optimized**: c5, c6i for CPU-intensive applications
- **Memory Optimized**: r5, r6i, x1e for memory-intensive workloads
- **Storage Optimized**: i3, d3 for high sequential read/write access

**AWS Lambda:** Serverless compute service executing code in response to events:

```python
import json

def lambda_handler(event, context):
    # Process event data
    name = event.get('name', 'World')
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Hello {name}!')
    }
```

**Storage Services:**

**Amazon S3 (Simple Storage Service):** Object storage service with multiple storage classes for different access patterns:

```bash
# Create S3 bucket
aws s3 mb s3://my-unique-bucket-name

# Upload file with storage class
aws s3 cp file.txt s3://my-bucket/ --storage-class GLACIER

# Sync directory
aws s3 sync ./local-folder s3://my-bucket/remote-folder/
```

Storage classes include Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant Retrieval, Glacier Flexible Retrieval, and Glacier Deep Archive.

**Amazon EBS (Elastic Block Store):** Persistent block storage for EC2 instances with multiple volume types:

- **gp3**: General purpose SSD with configurable IOPS and throughput
- **io2**: High IOPS SSD for mission-critical applications
- **st1**: Throughput optimized HDD for big data workloads
- **sc1**: Cold HDD for infrequently accessed data

**Networking Services:**

**Amazon VPC (Virtual Private Cloud):** Enables isolated network environments within AWS:

```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a
```

**Database Services:**

**Amazon RDS (Relational Database Service):** Managed database service supporting MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Aurora:

```bash
# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier mydb \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password mypassword \
    --allocated-storage 20
```

**Example Infrastructure as Code (CloudFormation):**

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0abcdef1234567890
      InstanceType: t3.micro
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for web server
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
```

### Azure Fundamentals

Microsoft Azure is a cloud computing platform providing infrastructure as a service (IaaS), platform as a service (PaaS), and software as a service (SaaS) solutions. Azure integrates closely with Microsoft's ecosystem including Active Directory, Office 365, and Windows Server.

**Azure Architecture:**

Azure organizes resources through a hierarchical structure: Management Groups > Subscriptions > Resource Groups > Resources. This structure enables governance, billing, and access control at different organizational levels.

**Key Points:**

- Azure operates in 60+ regions with 140+ availability zones
- Resource groups serve as logical containers for related Azure resources
- Azure Active Directory provides identity and access management
- Azure Resource Manager (ARM) templates enable infrastructure as code

**Core Compute Services:**

**Azure Virtual Machines:** IaaS offering providing Windows and Linux virtual machines:

```bash
# Create VM using Azure CLI
az vm create \
    --resource-group myResourceGroup \
    --name myVM \
    --image UbuntuLTS \
    --admin-username azureuser \
    --generate-ssh-keys \
    --size Standard_B2s
```

VM sizes are categorized into series:

- **B-series**: Burstable performance for variable workloads
- **D-series**: General purpose with SSD storage
- **F-series**: Compute optimized with high CPU-to-memory ratio
- **M-series**: Memory optimized for large databases

**Azure App Service:** PaaS for hosting web applications, APIs, and mobile backends:

```bash
# Create App Service plan and web app
az appservice plan create \
    --name myAppServicePlan \
    --resource-group myResourceGroup \
    --sku B1

az webapp create \
    --resource-group myResourceGroup \
    --plan myAppServicePlan \
    --name myUniqueWebApp \
    --runtime "NODE|14-lts"
```

**Azure Functions:** Serverless compute platform for event-driven applications:

```javascript
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    
    const name = (req.query.name || (req.body && req.body.name));
    const responseMessage = name
        ? "Hello, " + name + ". This HTTP triggered function executed successfully."
        : "This HTTP triggered function executed successfully.";

    context.res = {
        status: 200,
        body: responseMessage
    };
}
```

**Storage Services:**

**Azure Storage Account:** Provides blob, file, queue, and table storage services:

```bash
# Create storage account
az storage account create \
    --name mystorageaccount \
    --resource-group myResourceGroup \
    --location eastus \
    --sku Standard_LRS

# Upload blob
az storage blob upload \
    --account-name mystorageaccount \
    --container-name mycontainer \
    --name myblob.txt \
    --file ./local-file.txt
```

**Networking Services:**

**Azure Virtual Network (VNet):** Provides isolated network environments with subnets, network security groups, and routing:

```bash
# Create virtual network
az network vnet create \
    --resource-group myResourceGroup \
    --name myVNet \
    --address-prefix 10.0.0.0/16 \
    --subnet-name mySubnet \
    --subnet-prefix 10.0.1.0/24
```

**Database Services:**

**Azure SQL Database:** Managed relational database service based on SQL Server:

```bash
# Create SQL server and database
az sql server create \
    --name myserver \
    --resource-group myResourceGroup \
    --location eastus \
    --admin-user myadmin \
    --admin-password myPassword123!

az sql db create \
    --resource-group myResourceGroup \
    --server myserver \
    --name mydatabase \
    --service-objective Basic
```

**Example ARM Template:**

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmName": {
            "type": "string",
            "defaultValue": "myVM"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Compute/virtualMachines",
            "apiVersion": "2021-03-01",
            "name": "[parameters('vmName')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "hardwareProfile": {
                    "vmSize": "Standard_B2s"
                },
                "osProfile": {
                    "computerName": "[parameters('vmName')]",
                    "adminUsername": "azureuser",
                    "linuxConfiguration": {
                        "disablePasswordAuthentication": true
                    }
                }
            }
        }
    ]
}
```

### Google Cloud Introduction

Google Cloud Platform (GCP) leverages Google's infrastructure and expertise in areas like search, analytics, and machine learning. GCP emphasizes container orchestration, data analytics, and artificial intelligence services.

**GCP Infrastructure:**

Google Cloud organizes resources through Projects, which belong to Organizations and can contain Folders for hierarchical management. Each project provides isolated billing and resource management.

**Key Points:**

- GCP operates in 35+ regions with 100+ zones globally
- Projects serve as the primary resource organization unit
- Identity and Access Management (IAM) provides fine-grained access control
- Google's global network backbone connects regions and zones

**Compute Services:**

**Google Compute Engine:** IaaS providing virtual machines with custom machine types and preemptible instances:

```bash
# Create VM instance using gcloud CLI
gcloud compute instances create my-instance \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --subnet=default \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud
```

Machine families include:

- **E2**: Cost-optimized general purpose machines
- **N2**: Balanced performance and cost
- **C2**: Compute-optimized for CPU-intensive workloads
- **M2**: Memory-optimized for in-memory databases

**Google Kubernetes Engine (GKE):** Managed Kubernetes service with automatic scaling and updates:

```bash
# Create GKE cluster
gcloud container clusters create my-cluster \
    --zone us-central1-a \
    --num-nodes 3 \
    --enable-autoscaling \
    --min-nodes 1 \
    --max-nodes 10

# Deploy application
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment hello-app --type=LoadBalancer --port 80 --target-port 8080
```

**Cloud Functions:** Serverless execution environment for building and connecting cloud services:

```python
def hello_world(request):
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
        
    return f'Hello {name}!'
```

**Storage Services:**

**Google Cloud Storage:** Object storage with multiple storage classes and global accessibility:

```bash
# Create bucket
gsutil mb gs://my-unique-bucket-name

# Upload file with storage class
gsutil cp -s NEARLINE local-file.txt gs://my-bucket/

# Sync directory
gsutil -m rsync -r ./local-directory gs://my-bucket/remote-directory/
```

**Networking Services:**

**Google Virtual Private Cloud (VPC):** Global network infrastructure with subnet networks:

```bash
# Create VPC network
gcloud compute networks create my-vpc --subnet-mode custom

# Create subnet
gcloud compute networks subnets create my-subnet \
    --network my-vpc \
    --range 10.0.0.0/24 \
    --region us-central1
```

**Database Services:**

**Cloud SQL:** Managed relational database service supporting MySQL, PostgreSQL, and SQL Server:

```bash
# Create Cloud SQL instance
gcloud sql instances create myinstance \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=us-central1

# Create database
gcloud sql databases create mydatabase --instance=myinstance
```

**BigQuery:** Serverless data warehouse for analytics with SQL interface:

```sql
-- Query public dataset
SELECT
  name,
  SUM(number) as total
FROM `bigquery-public-data.usa_names.usa_1910_2013`
WHERE state = 'CA'
GROUP BY name
ORDER BY total DESC
LIMIT 10;
```

**Example Deployment Manager Template:**

```yaml
resources:
- name: my-vm
  type: compute.v1.instance
  properties:
    zone: us-central1-a
    machineType: zones/us-central1-a/machineTypes/e2-medium
    disks:
    - deviceName: boot
      type: PERSISTENT
      boot: true
      autoDelete: true
      initializeParams:
        sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts
    networkInterfaces:
    - network: global/networks/default
      accessConfigs:
      - name: External NAT
        type: ONE_TO_ONE_NAT
```

### Multi-Cloud Strategies

Multi-cloud strategies involve using services from multiple cloud providers to achieve specific business objectives including risk mitigation, cost optimization, performance improvement, and avoiding vendor lock-in.

**Multi-Cloud Architecture Patterns:**

**Distributed Architecture:** Different applications or services run on different cloud platforms based on their specific requirements and provider strengths.

**Key Points:**

- Enables leveraging best-of-breed services from each provider
- Requires managing multiple sets of tools, APIs, and billing systems
- [Inference] May increase operational complexity but provides flexibility
- Suitable for organizations with diverse workload requirements

**Hybrid Integration:** On-premises infrastructure connects with multiple cloud providers for burst capacity, disaster recovery, or specific workload placement.

**Data Distribution:** Data placement across multiple clouds based on regulatory requirements, performance needs, or cost considerations:

```bash
# Example: Sync data across cloud providers
# AWS to Azure
aws s3 sync s3://source-bucket ./temp-data
az storage blob upload-batch --destination container-name --source ./temp-data

# GCP to AWS
gsutil -m cp -r gs://source-bucket ./temp-data
aws s3 sync ./temp-data s3://destination-bucket
```

**Multi-Cloud Management Tools:**

**Terraform for Infrastructure as Code:** Terraform provides consistent infrastructure provisioning across cloud providers:

```hcl
# AWS provider
provider "aws" {
  region = "us-west-2"
}

# Azure provider
provider "azurerm" {
  features {}
}

# GCP provider
provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}

# Multi-cloud resources
resource "aws_instance" "web_server" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  
  tags = {
    Name        = "WebServer"
    Environment = "Production"
  }
}

resource "azurerm_virtual_machine" "app_server" {
  name                = "app-server"
  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_B2s"
  
  # Configuration details...
}

resource "google_compute_instance" "data_processor" {
  name         = "data-processor"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  
  # Configuration details...
}
```

**Container Orchestration:** Kubernetes provides consistent application deployment across cloud providers:

```yaml
# Multi-cloud deployment manifest
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-cloud-app
  labels:
    app: web-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-service
  template:
    metadata:
      labels:
        app: web-service
    spec:
      containers:
      - name: web-container
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
      nodeSelector:
        cloud-provider: aws  # or azure, gcp
```

**Multi-Cloud Networking:**

**VPN Connectivity:** Establish secure connections between cloud providers:

```bash
# AWS VPN Gateway setup
aws ec2 create-vpn-gateway --type ipsec.1

# Azure VPN Gateway
az network vnet-gateway create \
    --name VNet1GW \
    --public-ip-address VNet1GWIP \
    --resource-group TestRG1 \
    --vnet VNet1 \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1

# GCP VPN Gateway
gcloud compute vpn-gateways create my-vpn-gateway \
    --network my-network \
    --region us-central1
```

**Service Mesh for Multi-Cloud:** Istio service mesh can span multiple Kubernetes clusters across cloud providers:

```yaml
# Istio gateway for multi-cloud traffic
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: multi-cloud-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - api.example.com
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: api-cert
    hosts:
    - api.example.com
```

**Cost Optimization Strategies:**

**Reserved Instance Planning:** [Inference] Purchasing reserved instances across multiple providers based on predictable workload patterns can reduce costs compared to on-demand pricing.

**Spot Instance Utilization:** Leverage spot/preemptible instances across providers for fault-tolerant workloads:

```bash
# AWS Spot Fleet
aws ec2 create-spot-fleet --spot-fleet-request-config file://spot-fleet-config.json

# Azure Spot VMs
az vm create \
    --resource-group myResourceGroup \
    --name mySpotVM \
    --image UbuntuLTS \
    --priority Spot \
    --max-price 0.05

# GCP Preemptible instances
gcloud compute instances create preemptible-instance \
    --preemptible \
    --zone us-central1-a
```

**Data Transfer Optimization:** Minimize inter-cloud data transfer costs through strategic data placement and caching:

```python
# Example: Multi-cloud data synchronization strategy
class MultiCloudDataManager:
    def __init__(self):
        self.aws_client = boto3.client('s3')
        self.azure_client = BlobServiceClient()
        self.gcp_client = storage.Client()
    
    def replicate_data(self, source_provider, destination_providers, data_key):
        # Intelligent replication based on access patterns
        for dest_provider in destination_providers:
            if self.should_replicate(data_key, dest_provider):
                self.transfer_data(source_provider, dest_provider, data_key)
    
    def should_replicate(self, data_key, provider):
        # [Inference] Decision logic based on access patterns, 
        # compliance requirements, and cost analysis
        access_pattern = self.get_access_pattern(data_key)
        compliance_req = self.get_compliance_requirements(data_key)
        return self.evaluate_replication_benefit(access_pattern, compliance_req, provider)
```

**Monitoring and Observability:**

Multi-cloud monitoring requires centralized observability platforms:

```yaml
# Prometheus configuration for multi-cloud monitoring
global:
  scrape_interval: 15s

scrape_configs:
- job_name: 'aws-instances'
  ec2_sd_configs:
  - region: us-west-2
    port: 9100

- job_name: 'azure-instances'
  azure_sd_configs:
  - subscription_id: 'subscription-id'
    resource_group: 'monitoring-rg'
    port: 9100

- job_name: 'gcp-instances'
  gce_sd_configs:
  - project: 'my-project-id'
    zone: 'us-central1-a'
    port: 9100
```

**Governance and Compliance:**

**Policy as Code:** Implement consistent governance across cloud providers:

```python
# Example: Multi-cloud policy enforcement
class MultiCloudGovernance:
    def __init__(self):
        self.policies = {
            'encryption': {'required': True, 'algorithm': 'AES-256'},
            'backup': {'frequency': 'daily', 'retention': '30d'},
            'access': {'mfa_required': True, 'session_timeout': '8h'}
        }
    
    def validate_compliance(self, resource, provider):
        compliance_status = {}
        for policy_name, policy_config in self.policies.items():
            compliance_status[policy_name] = self.check_policy_compliance(
                resource, policy_config, provider
            )
        return compliance_status
    
    def remediate_non_compliance(self, resource, provider, violations):
        # [Unverified] Automated remediation procedures vary by provider
        # and may require provider-specific implementation
        for violation in violations:
            self.apply_remediation(resource, violation, provider)
```

**Output:** Multi-cloud strategies require careful planning around architecture patterns, tooling, networking, cost optimization, and governance to successfully leverage multiple cloud providers while managing complexity and ensuring operational efficiency.

---

