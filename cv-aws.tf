
provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-cv-test-bucket-0515812"
  acl    = "private"

}

resource "aws_security_group" "allow_cv" {
  name        = "allow_cv"
  description = "Allow Commvault inbound traffic"
  vpc_id      = "vpc-9b33c9eb"


  ingress {
    # TLS (change to whatever ports you need)
    from_port = 8400
    to_port   = 8403
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["63.101.87.0/24"]
  }

  ingress {
    # SSH
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["63.101.87.0/24"]
  }

  ingress {
    # SSH
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_instance_profile" "cvprofile" {
  name = "cvprofile"
  role = aws_iam_role.cvrole.name
}

resource "aws_iam_role_policy" "cvpolicy" {
  name = "cvpolicy"
  role = aws_iam_role.cvrole.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:CreateBucket",
        "s3:ListAllMyBuckets",
        "s3:PutObject",
        "s3:GetObject",
        "s3:PutObjectTagging",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cvrole" {
  name = "cvrole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ec2.amazonaws.com"
          ]
      },
        "Action": "sts:AssumeRole"
    }
    ]
  }
EOF
}

resource "aws_instance" "CVMediaAgent" {
  ami                  = "ami-0adbcc0bde99c2574"
  instance_type        = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.cvprofile.name

  security_groups = ["allow_cv"]
  key_name        = "CVKeyPair"
}
