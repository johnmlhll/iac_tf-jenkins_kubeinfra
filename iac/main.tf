data "aws_ssm_parameter" "subnet-public" {
    name    =   "/examplevpc/pub_subnet"
    with_decryption =   true
}

data "aws_ssm_parameter" "subnet-private" {
    name    =   "/examplevpc/pte_subnet"
    with_decryption =   true
}

data "aws_ssm_parameter" "vpc_target" {
    name    =   "my-vpc"
    with_decryption =   true
}

data "aws_ssm_parameter" "vpn_allow_cidr" {
    name    =   "/examplevpc/allow_vpn"
    with_decryption     =   true
}

data "aws_ssm_parameter" "k8s_cidr" {
    name    =  "/examplevpc/k8s16"
    with_decryption =   true
}

resource "aws_security_group" "sg_k8s" {
    name    =   "sg_k8s-nodes"
    description =   "Allow admin and k8s deployed EC2 controller and worker nodes."
    vpc_id  =   data.aws_ssm_parameter.vpc_target.value

    timeouts {
        delete  =   "3m"
    }
    
    lifecycle {
        create_before_destroy   =   true
    }
    
    tags = {
        Name = "SgAccess-${var.primary_node_name}"
        NodePurpose = var.node_purpose
        NodeOs  =   var.node_os
    }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_ssh_allow_ipv4" {
    security_group_id   =   aws_security_group.sg_k8s.id
    description =   "SSH access from authorized vpn cidr"
    cidr_ipv4   =   data.aws_ssm_parameter.vpn_allow_cidr.value
    from_port   =   22
    ip_protocol =   "tcp"
    to_port     =   22

    tags = {
        Name = "SSH VPN"
        Type = "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_k8s_vpc" {
    security_group_id   =   aws_security_group.sg_k8s.id
    description     =   "Private VPC Cidr Inbound Access"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   8080
    ip_protocol =   "tcp"
    to_port     =   8080

    tags = {
        Name = "Private http VPC Cidr Inbound Access"
        Type = "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_api_server" {
    security_group_id   =   aws_security_group.sg_k8s.id 
    description     =   "Kube API server access for bridged ETCD api interation"
    cidr_ipv4       =   data.aws_ssm_parameter.k8s_cidr.value 
    from_port       =   6443
    ip_protocol     =   "tcp"
    to_port         =   6443

    tags = {
        Name = "K8S API Server"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "etcd_server" {
    security_group_id   =   aws_security_group.sg_k8s.id 
    description =   "ETCD Server Access for Control to Data Plane state"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   2379
    ip_protocol =   "tcp"
    to_port     =   2380

    tags = {
        Name = "ETCD Server"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api_write" {
    security_group_id   =   aws_security_group.sg_k8s.id 
    description =   "Kubelet API, K8s Scheduler, and Controller Manager Write Access"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   10250
    ip_protocol =   "tcp"
    to_port     =   10252

    tags = {
        Name = "K8s API Write-Ops"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api_read" {
    security_group_id   =   aws_security_group.sg_k8s.id 
    description =   "kublet Read Only, controller and kube-proxy Access"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   10255
    ip_protocol =   "tcp"
    to_port     =   10257

    tags = {
        Name = "Kube cluster mgt"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_worker_health" {
    security_group_id   =   aws_security_group.sg_k8s.id 
    description =   "kublet worker health rule inbound"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   10259
    ip_protocol =   "tcp"
    to_port     =   10259

    tags = {
        Name = "K8s Worker Healthcheck"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_ingress_rule" "nodeports_svc" {
    security_group_id   =   aws_security_group.k8s_node_sg.id 
    description =   "Nodeport range for external services"
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    from_port   =   30000
    ip_protocol =   "tcp"
    to_port     =   32767

    tags = {
        Name = "Nodeport SVC"
        Type =  "SecurityRule"
    }
}

resource "aws_vpc_security_group_egress_rule" "allow_out" {
    security_group_id   =   aws_security_group.sg_k8s.id
    cidr_ipv4   =   data.aws_ssm_parameter.k8s_cidr.value
    ip_protocol =   -1

    tags = {
        Name = "Master Outbound"
        Type =  "SecurityRule"
    }
}

resource "aws_instance" "k8s_controller" {
    ami = lookup(var.ami_ubuntu_22, var.region)
    instance_type = var.master_type
    count = 1
    subnet_id = data.aws_ssm_parameter.subnet-public.value
    vpc_security_group_ids = [aws_security_group.sg_k8s.id]
    key_name = var.ssh_key
    associate_public_ip_address =   "true"

    tags = {
        Name    =   "${var.primary_node_name}-Master"
        NodeName = var.node_name
        Purpose = var.node_purpose
        NodeOs = var.node_os
    }

    lifecycle {
        ignore_changes = [associate_public_ip_address]
    }
}

resource "aws_instance" "k8s_worker" {

    ami = lookup(var.ami_ubuntu_22, var.region)
    instance_type = var.worker_type
    count = 2
    subnet_id = data.aws_ssm_parameter.subnet-private.value
    vpc_security_group_ids = [aws_security_group.sg_k8s.id]
    key_name = var.ssh_key
    associate_public_ip_address =   "true"

    tags = {
        Name    =   "${var.secondary_node_name}-${count.index}"
        NodeName = var.secondary_node_name
        Purpose = var.node_purpose
        NodeOs = var.node_os
    }

    lifecycle {
        ignore_changes = [associate_public_ip_address]
    }
}