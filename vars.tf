# variables
# Private subnet in us-east-1b AZ in VPC1
variable "subnet_prefix1" {
  description = "cidr block for the subnet1 in VPC1"
}

# Private subnet in us-east-1a AZ in VPC1
variable "subnet_prefix2" {
  description = "cidr block for the subnet2 in VPC1"
}

# Public subnet in VPC2
variable "subnet_prefix3" {
  description = "cidr block for the subnet3 in VPC2"
}

# Private subnet in VPC2
variable "subnet_prefix4" {
  description = "cidr block for the subnet4 in VPC2"
}

variable "myIP" {
  description = "assigning my PC IP for Security groups"
}

variable "public_key" {
  description = "assigning my PC IP for Security groups"
}

variable "database-instance-identifier" {
  description = "Postgres database instance identifier"
  type        = string
}

variable "database-instance-class" {
  description = "Postgres database instance type"
  type        = string
}

variable "multi-az-deployment" {
  description = "create a standby databbase"
  type        = bool
}

variable "peer-owner-id" {
  description = "AWS account ID for VPC peering"
}

variable "cloudtrail_s3_bucket" {
  default = ""
}

variable "cloudtrail_cloudwatch_role_name" {
  default = ""
}

variable "cloudtrail_cloudwatch_role_policy_name" {
  default = ""
}

variable "cloudtrail_name" {
  default = ""
}