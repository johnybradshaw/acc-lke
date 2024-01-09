# main.tf

# This file is used to create a Linode Kubernetes Engine (LKE) cluster.
resource "random_string" "cluster_suffix" {
  length = 4
  special = false
  upper = false
  numeric = false
}

// Create the LKE cluster
resource "linode_lke_cluster" "lke_cluster" {
  provider = linode.default # Use the default Linode provider

  label       = "${var.lke_cluster.name}-${random_string.cluster_suffix.result}"
  region      = var.lke_cluster.region
  k8s_version = var.lke_cluster.k8s_version
  tags        = var.lke_cluster.tags
  control_plane {
    high_availability = var.lke_cluster.high_availability # Enable or disable high availability
  }

  dynamic "pool" { # Create a node pool for each pool in the LKE cluster
    for_each = var.lke_cluster.node_pools
    content {
      type  = pool.value.type
      count = pool.value.count
      autoscaler {
        min = pool.value.autoscaler.min_nodes
        max = pool.value.autoscaler.max_nodes
      }
    }
  }  

  // Prevent lifecycle changes to the LKE cluster
  lifecycle {
    ignore_changes = [
      pool.0.count
    ]
  }
}

// Create variables based on the LKE cluster
locals {
    cluster_node_ids = flatten([for pool in linode_lke_cluster.lke_cluster.pool : [for node in pool.nodes : node.instance_id]])
    cluster_tags = jsonencode(concat([var.lke_cluster.name], var.lke_cluster.tags))

    # Decode the kubeconfig
    kube_config_decoded = base64decode(linode_lke_cluster.lke_cluster.kubeconfig)
    kube_config_map     = yamldecode(local.kube_config_decoded)
    user_name           = local.kube_config_map.users[0].name
    user_token          = local.kube_config_map.users[0].user.token
}

// Update CoreDNS to use external resolver to enable DoT
resource "kubectl_manifest" "coredns" {

  depends_on = [ linode_lke_cluster.lke_cluster ]

    yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . tls://9.9.9.9 {
          tls_servername dns.quad9.net
          health_check 5s domain akamai.com
        }
        cache 30
        loop
        reload
        loadbalance
    }
YAML
}