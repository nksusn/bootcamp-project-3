#############################
# IAM Policy for IRSA (External Secrets)
#############################

data "aws_iam_policy_document" "irsa_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, ":oidc-provider/", ":sub")}"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "ExternalSecretsPolicy"
  description = "Permissions for External Secrets Operator"

  policy = file("external-secrets-policy.json")
}

resource "aws_iam_role" "external_secrets_irsa" {
  name               = "external-secrets-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_policy.json

  tags = {
    Project = var.cluster_name
  }
}

resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
