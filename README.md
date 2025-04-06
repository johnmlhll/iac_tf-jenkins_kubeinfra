# iac_tf-jenkins_kubeinfra
Public repository for deploying EC2 node intances in support of a Kubernetes cluser. It will be configured for a Kubernetes overlay via manual means, or automated means via ansible. This is a provisioning repository for customer managed kubernetes clusters on AWS. 

# pre-requisites
AWS Parameter store for infrastructure provisioning is referenced in this deployment, as is a pre-existing VPC with subnets, to host the kubernetes cluster. 
