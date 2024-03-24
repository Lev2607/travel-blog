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

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "travelBlog_ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
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

# IAM Policy
resource "aws_iam_policy" "s3_put_bucket_policy" {
  name        = "s3_put_bucket_policy"
  description = "Allows s3:PutBucketPolicy on travelblog-images bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutBucketPolicy",
      "Resource": "arn:aws:s3:::travelblog-images"
    }
  ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_put_bucket_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_put_bucket_policy.arn
}

# EC2 Instanz mit IAM Rollen und Key Pair
resource "aws_instance" "web_server" {
  ami           = "ami-023adaba598e661ac" 
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

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
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "s3:*",
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

# Erstellung der Lambda-Rolle
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Berechtigung für die Lambda-Funktion, um auf DynamoDB zuzugreifen
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_policy"
  description = "Policy for accessing DynamoDB from Lambda"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      Resource  = "*"
    }]
  })
}

# Anfügen der DynamoDB-Berechtigung an die Lambda-Rolle
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Neue Lambda-Funktion erstellen
resource "aws_lambda_function" "comments_lambda" {
  function_name    = "CommentsFunction"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = "/home/lev/travel-blog/lambda/myLambdaFunction.zip"
  source_code_hash = filebase64sha256("/home/lev/travel-blog/lambda/myLambdaFunction.zip")
}

# Erstellung der API-Gateway-Ressourcen

resource "aws_api_gateway_rest_api" "comments_api" {
  name        = "comments_api"
  description = "API for managing comments"
}

resource "aws_api_gateway_resource" "comments_resource" {
  rest_api_id = aws_api_gateway_rest_api.comments_api.id
  parent_id   = aws_api_gateway_rest_api.comments_api.root_resource_id
  path_part   = "comments"
}

# Erstellung der GET-Methode für das API-Gateway
resource "aws_api_gateway_method" "get_comments_method" {
  rest_api_id   = aws_api_gateway_rest_api.comments_api.id
  resource_id   = aws_api_gateway_resource.comments_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Erstellung der Integration für die GET-Methode
resource "aws_api_gateway_integration" "get_comments_integration" {
  rest_api_id             = aws_api_gateway_rest_api.comments_api.id
  resource_id             = aws_api_gateway_resource.comments_resource.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.comments_lambda.invoke_arn
}

# Erstellung der Methodenantwort für die GET-Methode
resource "aws_api_gateway_method_response" "comments_method_response" {
  rest_api_id = aws_api_gateway_rest_api.comments_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.get_comments_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Erstellung der Integrationsantwort für die GET-Methode
resource "aws_api_gateway_integration_response" "comments_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.comments_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = "GET"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://18.197.158.249'"
  }
}

resource "aws_api_gateway_method" "comments_put_method" {
  rest_api_id   = aws_api_gateway_rest_api.comments_api.id
  resource_id   = aws_api_gateway_resource.comments_resource.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "comments_put_method_response" {
  rest_api_id = aws_api_gateway_rest_api.comments_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_put_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "comments_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.comments_api.id
  resource_id             = aws_api_gateway_resource.comments_resource.id
  http_method             = "PUT"
  integration_http_method = "POST"  # Sie können dies an Ihre Anforderungen anpassen
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.comments_lambda.invoke_arn
}

resource "aws_api_gateway_integration_response" "comments_put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.comments_api.id
  resource_id = aws_api_gateway_resource.comments_resource.id
  http_method = aws_api_gateway_method.comments_put_method.http_method
  status_code = aws_api_gateway_method_response.comments_put_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'http://18.197.158.249'"
  }
}

