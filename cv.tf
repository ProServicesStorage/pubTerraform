terraform {

  required_providers {

    commvault = {

      source = "Commvault/commvault"

    }

  }

}

provider "commvault" {

  web_service_url = "http://trout:81/SearchSvc/CVWebService.svc/"

  user_name = "admin"

  password = "H03QOHXINEI="

}

resource "commvault_aws_storage" "CloudLib" {

  storage_name = "aws_lib1"

  mediaagent = "13.57.27.58"

  service_host = "s3.us-west-1.amazonaws.com"

  bucket = "my-cv-test-bucket-0515812"

  credentials_name = "TestCred"

  ddb_location = "/mnt/commvault_ddb/1"

}

resource "commvault_plan" "Plan1" {

  plan_name = "Server Plan"

  retention_period_days = 30

  backup_destination_name = "aws_lib1"

  backup_destination_storage = "aws_lib1"

  depends_on = [
    commvault_aws_storage.CloudLib,
  ]

}