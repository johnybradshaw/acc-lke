# variables.tf

variable "linode_config" {
  type = object({
    api_token = string
  })
}

variable "lke_cluster" {
  description = "LKE Cluster Configuration"
  type = object({
    name        = string         // Name of the LKE cluster
    region      = string         // Linode region for the LKE cluster
    k8s_version = string         // Kubernetes version for the LKE cluster
    high_availability = bool     // Enable or disable high availability
    tags        = list(string)   // Tags for the LKE cluster
    node_pools  = list(object({  // List of node pools for the LKE cluster
      type  = string             // Type of nodes in the pool
      count = number             // Number of nodes in the pool
      autoscaler = optional(object({
        min_nodes = number
        max_nodes = number
      }))         // Enable or disable autoscaling 
    }))
  })
  default = {
    name = "lke-cluster"
    region = "fr-par"
    k8s_version = "1.28"
    high_availability = true
    tags = ["acc", "k8s", "lke"]
    node_pools = [
      {
        type = "g6-standard-2"
        count = 3
        autoscaler = {
          min_nodes = 3
          max_nodes = 5
        }
      }
    ]
  }
}