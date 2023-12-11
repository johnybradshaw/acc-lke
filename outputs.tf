# outputs.tf

output "cluster_id" {
  description = "The ID of the LKE cluster generated"
  value       = linode_lke_cluster.lke_cluster.id
}

output "cluster_link" {
  description = "The link to the LKE cluster in the Linode Cloud Manager."
  value       = "https://cloud.linode.com/kubernetes/clusters/${linode_lke_cluster.lke_cluster.id}/summary"
}

output "cluster_endpoint" {
  description = "The API endpoint for the deployed LKE cluster."
  value       = linode_lke_cluster.lke_cluster.api_endpoints[0]
}

output "cluster_nodes" {
  description = "List of node IDs for the deployed LKE cluster."
  value       = local.cluster_node_ids
}

output "cluster_tags" {
  description = "The tags for the deployed LKE cluster."
  value = jsondecode(local.cluster_tags)
}

output "cluster_kubeconfig" {
  description = "The Kubeconfig file for the deployed LKE cluster."
  value       = linode_lke_cluster.lke_cluster.kubeconfig
  sensitive   = true
}
