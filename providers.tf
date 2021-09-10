# create region-master and region-worker providers in aws
provider "aws" {
	profile = var.profile
	region = var.region-master
	alias = "region-master"
}
provider "aws" {
        profile = var.profile
        region = var.region-worker
        alias = "region-worker"
}
