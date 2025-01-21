terraform {
  required_version = "~> 1.8.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.21"
    }
  }

  backend "s3" {
    bucket = "demo512"
    key    = "terraform/snapshot/state.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "aws_lab"
  # profile = "default"
  region  = "us-east-2"
}

/*
# all the subnets in the aws region
data "aws_subnets" "all_subnets" {
	provider = aws.aws_lab
    filter {
    name   = "tag:Name"
    values = ["${var.env}-abc-subnet-1-pub"]
  }
}

output "ami_id" {
  value = data.aws_ami.example.id
}



# Provider configuration
provider "aws" {
  region = "us-west-2" # Change to the desired region
}
*/
# Data source to get EC2 instance details
data "aws_instance" "target_instance" {
  provider = aws.aws_lab
  instance_id = "i-1234567890abcdef0" # Replace with your instance ID
}

# Fetch all attached volumes of the instance
data "aws_ebs_volumes" "attached_volumes" {
  provider = aws.aws_lab
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instance.target_instance.id]
  }
}

# Snapshot a specific volume by ID
resource "aws_ebs_snapshot" "target_snapshot" {
  provider = aws.aws_lab
  volume_id = "vol-0987654321abcdef0" # Replace with the specific volume ID
  tags = {
    Name        = "MySnapshot"
    CreatedBy   = "Terraform"
  }
}

# Output all attached volumes
output "attached_volumes" {
  value = data.aws_ebs_volumes.attached_volumes.ids
}
