resource "aws_ram_resource_share" "this" {
  name                      = var.name
  allow_external_principals = var.allow_external_principals

  tags = {
    Name = var.name
  }
}

resource "aws_ram_resource_association" "this" {
  # Map keys must be static so ARNs can be apply-time unknowns.
  for_each = var.resolver_rules

  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_principal_association" "this" {
  for_each = toset(var.principal_account_ids)

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this.arn
}
