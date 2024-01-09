# terraform.tf

terraform {
    required_version = ">= 1.5.7"

    required_providers {
        linode = {
            source = "linode/linode"
            version = ">= 2.9.3"
            #configuration_aliases = [ linode.default ]
        }
        kubectl = {
            source  = "alekc/kubectl"
            version = ">= 2.0.2"
            #configuration_aliases = [ kubectl.default ]
        }
        random = {
            source = "hashicorp/random"
            version = ">= 2.3.0"
            #configuration_aliases = [ random.default ]
        }
    }
}

provider "linode" {
    alias = "default"
    
    token = var.linode_config.api_token
}

# Initialise the Kubernetes provider
provider "kubernetes" {

    host  = local.kube_config_map.clusters[0].cluster.server
    token = local.user_token

    cluster_ca_certificate = base64decode(
        local.kube_config_map.clusters[0].cluster["certificate-authority-data"]
    )
}

# Initialise kubectl
provider "kubectl" {

    host  = local.kube_config_map.clusters[0].cluster.server
    token = local.user_token

    cluster_ca_certificate = base64decode(
        local.kube_config_map.clusters[0].cluster["certificate-authority-data"]
    )

    load_config_file = false # Disables local loading of the KUBECONFIG
    apply_retry_count = 15 # Allows kubernetes commands to be retried
}