# iac_tf-jenkins_kubeinfra
Public repository for deploying EC2 node intances in support of a Kubernetes cluster. It can be configured for a Kubernetes overlay via manual means, or automated means via ansible. This is a basic provisioning repository for customer managed kubernetes clusters on AWS. The infrastructure as code is written in (HCL) declarative terraform, and the pipeline is written for a Jenkins.

# repo-briefing
AWS Parameter store for infrastructure provisioning is referenced in this deployment, as is a pre-existing VPC with subnets, to host the kubernetes cluster. This deployment also assumes, the VPC subnets are correctly configured. 

Do note the security group rules that points to the private k8s cidr are locking down the cluster's nodes for security purposes. The VPN cidr variable expressed in security rules is instead of general internet access to the public subnet. 

This is a base provisioning deployment for a customer managed cluster, which can be buily upon per your use case. Advanced infrastructure assets like firewalls, or vpc features like internet gateways were not included, but are advisable in a real use case.

For Production, you would need to update public subnets with external routing rules to allow external access. Also, ensure private subnets are indeed NACL private with a NAT connection in public subnet. Private nodes in the private subnet should be associated with the public (node) security group only. This will enable a kubeadm deployment to be successfully deployed as a node overlay.
