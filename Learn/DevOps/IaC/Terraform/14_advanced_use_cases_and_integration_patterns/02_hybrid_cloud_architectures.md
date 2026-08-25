## Hybrid Cloud Architectures


### On-Premises to Cloud Connectivity

```hcl
# hybrid-connectivity.tf
# AWS Direct Connect
resource "aws_dx_gateway" "main" {
  name = "${var.environment}-dx-gateway"
}

resource "aws_dx_gateway_association" "main" {
  dx_gateway_id  = aws_dx_gateway.main.id
  vpn_gateway_id = aws_vpn_gateway.main.id
}

# Azure ExpressRoute
resource "azurerm_express_route_circuit" "main" {
  name                  = "${var.environment}-expressroute"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  service_provider_name = var.express_route_provider
  peering_location      = var.express_route_location
  bandwidth_in_mbps     = var.express_route_bandwidth
  
  sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}

# Google Cloud Interconnect
resource "google_compute_interconnect_attachment" "main" {
  name                     = "${var.environment}-interconnect"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  type                     = "PARTNER"
  router                   = google_compute_router.main.id
  region                   = var.gcp_region
}
```

### Hybrid DNS Configuration

```hcl
# hybrid-dns.tf
# AWS Route 53 Resolver
resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "${var.environment}-inbound"
  direction = "INBOUND"
  
  security_group_ids = [aws_security_group.dns_resolver.id]
  
  dynamic "ip_address" {
    for_each = var.resolver_subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

resource "aws_route53_resolver_rule" "onprem" {
  domain_name          = var.onprem_domain
  name                 = "${var.environment}-onprem-rule"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  
  dynamic "target_ip" {
    for_each = var.onprem_dns_servers
    content {
      ip = target_ip.value
    }
  }
}

# Azure Private DNS
resource "azurerm_private_dns_zone" "main" {
  name                = var.private_domain
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "${var.environment}-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = true
}
```

### Identity Federation

```hcl
# identity-federation.tf
# AWS SAML Identity Provider
resource "aws_iam_saml_identity_provider" "main" {
  name                   = "${var.environment}-saml-provider"
  saml_metadata_document = file("${path.module}/saml-metadata.xml")
}

# Azure AD Integration
resource "azuread_application" "main" {
  display_name = "${var.environment}-terraform-app"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "main" {
  application_id = azuread_application.main.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

# GCP Workload Identity
resource "google_service_account" "main" {
  account_id   = "${var.environment}-terraform-sa"
  display_name = "Terraform Service Account"
}

resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "serviceAccount:${var.gcp_project}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account}]"
  ]
}
```

