provider "aws" {
  region = "eu-central-1"
}

# IAM Rolle für EC2 Instanz mit Berechtigungen 
resource "aws_iam_role" "ec2_role" {
  name = "travelBlog_ec2_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Policy zur IAM Rolle, um auf S3 und DynamoDB zugreifen zu können

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "travelBlog_s3_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "dynamodb_policy_attachment" {
  name       = "travelBlog_dynamodb_policy_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# EC2 Instanz mit IAM Rolle

resource "aws_instance" "web_server" {
  ami           = "ami-064573ac645743ea8"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_role.ec2_role.name

  tags = {
    Name = "travelBlogInstance"
  }
}

# S3 Bucket

resource "aws_s3_bucket" "image_bucket" {
  bucket = "travelblog-images"

  tags = {
    Name = "travelBlogImageBucket"
  }
}

resource "aws_s3_bucket_policy" "image_bucket_policy" {
  bucket = aws_s3_bucket.image_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.image_bucket.arn}/*",
        ]
      },
    ]
  })
}

# DynamoDB Table für die Kommentare

resource "aws_dynamodb_table" "comments_table" {
  name           = "travelBlogComments"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Name = "travelBlogCommentsTable"
  }
}