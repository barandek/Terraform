# Master will be on us-east-1 
# Worker on us-east-2

variable "profile" {
	type = string
	default = "bnycz"
}

variable "region-master" {
	type = string
	default = "us-east-1"
}

variable "region-worker" {
        type = string
        default = "us-east-2"
}
