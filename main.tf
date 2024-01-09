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
}