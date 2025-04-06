terraform {
    required_version = ">= 0.13"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket = "terraformconfig"
        key = "state/cluster.tfstate"
        region = "us-east-2"
        encrypt = true
    }
}

provider "aws" {
    region = "us-east-2"
    assume_role {
        role_arn = "arn:aws:iam::xxxxxxxxxxxx:role/IamTrustRole"
        external_id = "TightenSecurityPhrase"
    }
}