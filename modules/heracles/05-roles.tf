# Create a role which Heracles instances will assume.
# This role has a policy saying it can be assumed by ec2
# instances.
resource "aws_iam_role" "heracles-instance-role" {
  name = "heracles-instance-role"

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

# This policy allows an instance to forward logs to CloudWatch, and
# create the Log Stream or Log Group if it doesn't exist.
resource "aws_iam_policy" "heracles-policy-forward-logs" {
  name        = "heracles-instance-forward-logs"
  path        = "/"
  description = "Allows an instance to forward logs to CloudWatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

# Attach the policies to the roles.
resource "aws_iam_policy_attachment" "heracles-attachment-forward-logs" {
  name       = "heracles-attachment-forward-logs"
  roles      = [aws_iam_role.heracles-instance-role.name]
  policy_arn = aws_iam_policy.heracles-policy-forward-logs.arn
}

# Create a instance profile for the role.
resource "aws_iam_instance_profile" "heracles-instance-profile" {
  name  = "heracles-instance-profile"
  role = aws_iam_role.heracles-instance-role.name
}

# Create a instance profile for the control. All profiles need a role, so use
# our simple Heracles instance role.
resource "aws_iam_instance_profile" "heracles-control-instance-profile" {
  name  = "heracles-control-instance-profile"
  role = aws_iam_role.heracles-instance-role.name
}

# Create a instance profile for the control. All profiles need a role, so use
# our simple Heracles instance role.
resource "aws_iam_instance_profile" "heracles-nginx-instance-profile" {
  name  = "heracles-nginx-instance-profile"
  role = aws_iam_role.heracles-instance-role.name
}

# Create a instance profile for the control. All profiles need a role, so use
# our simple Heracles instance role.
resource "aws_iam_instance_profile" "heracles-spring-instance-profile" {
  name  = "heracles-spring-instance-profile"
  role = aws_iam_role.heracles-instance-role.name
}

# Create a instance profile for MySQL Database. All profiles need a role, so use
# our simple Heracles instance role.
resource "aws_iam_instance_profile" "heracles-mysql-instance-profile" {
  name  = "heracles-mysql-instance-profile"
  role = aws_iam_role.heracles-instance-role.name
}

# Create a user and access key for heracles-only permissions
resource "aws_iam_user" "heracles-aws-user" {
  name = "heracles-aws-user"
  path = "/"
}

# Create a IAM User Policy
resource "aws_iam_user_policy" "heracles-aws-user" {
  name = "heracles-aws-user-policy"
  user = aws_iam_user.heracles-aws-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVolume*",
        "ec2:CreateVolume",
        "ec2:CreateTags",
        "ec2:DescribeInstance*",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeSubnets",
        "ec2:CreateSecurityGroup",
        "ec2:DescribeSecurityGroups",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "ec2:DescribeRouteTables",
        "elasticloadbalancing:ConfigureHealthCheck",
        "ec2:AuthorizeSecurityGroupIngress",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancerAttributes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create a IAM Access Key
resource "aws_iam_access_key" "heracles-aws-user" {
  user = aws_iam_user.heracles-aws-user.name
}

# Create an SSH keypair
resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}