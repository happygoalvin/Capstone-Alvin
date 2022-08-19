# Enable AWS Security Hub Account
resource "aws_securityhub_account" "alvin_sec_hub" {}

# Subscribe to security hub cis-aws-foundations-benchmark 
resource "aws_securityhub_standards_subscription" "alvin_sec_hub_cis_foundations" {
  depends_on    = [aws_securityhub_account.alvin_sec_hub]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

#Subscribe to security hub pci-dss standard
resource "aws_securityhub_standards_subscription" "alvin_sec_hub_pci321" {
  depends_on    = [aws_securityhub_account.alvin_sec_hub]
  standards_arn = "arn:aws:securityhub:${var.region}::standards/pci-dss/v/3.2.1"
}

# Subscribe to security hub aws foundational best practices standard
resource "aws_securityhub_standards_subscription" "alvin_sechub_best_prac" {
  depends_on    = [aws_securityhub_account.alvin_sec_hub]
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}
