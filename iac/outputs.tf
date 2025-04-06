output "public_ip_master" {
    description = "Public IP for EC2 instance for Kubernetes master nodes. "
    value = aws_instance.k8s_master[*].public_ip
}

output "instance_id_controller" {
    description = "EC2 Instance ID for the infra master K8s nodes"
    value = aws_instance.k8s_master[*].id 
}

output "public_ip_worker" {
    description = "Public IP for EC2 instance for Kubernetes worker nodes."
    value = aws_instance.k8s_worker[*].public_ip
}

output "instance_id_slave" {
    description = "EC2 Instance ID for the infra worker K8s nodes"
    value = aws_instance.k8s_worker[*].id 
}