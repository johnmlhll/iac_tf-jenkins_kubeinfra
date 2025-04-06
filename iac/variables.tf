variable "ami_ubuntu_22" {
    type = map

    default = {
        us-east-1 = "ami-xxxxxxxxxxxxxxxxx"
        us-east-2 = "ami-xxxxxxxxxxxxxxxxx"
        us-west-1 = "ami-xxxxxxxxxxxxxxxxx"
    }
}

variable "region" {
    description = "Target AWS region for deployment"
    default = "us-east-2" 
}

variable "master_type" {
    type = string
    description = "K8s controller instance deployed onto AWS"
    default = "t2.medium"
}

variable "worker_type" {
    type = string
    description = "K8s worker instance deployed onto AWS"
    default = "t2.micro"
}

variable "primary_node_name" {
    type = string
    description = "EC2 management node for AWS deployment"
    default = "K8sController"
}

variable "secondary_node_name" {
    type    =   string 
    description =   "EC2 worker node secondary name designation"
    default = "K8sSlave"
}

variable "node_purpose" {
    type = string
    description = "Purpose of launching EC2 nodes"
    default = "DevOps_Training"
}

variable "node_os" {
    type = string
    description = "OS name called back via AMI"
    default = "Ubuntu_22_04"
}

variable "ssh_key" {
    type = string 
    description = "SSH Key for Kubernetes node access deployed via cicd"
    default = "k8s-ssh-access-key"
}