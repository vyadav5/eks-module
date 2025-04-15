data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_session_context" "current" {

  arn = try(data.aws_caller_identity.current.arn, "")
}

#fetch latest api version
data "external" "get_k8s_api_version" {
  program = ["sh", "-c", "aws eks get-token --cluster-name test-cluster --output json | jq -r '{\"apiVersion\": .apiVersion}'"]
}


