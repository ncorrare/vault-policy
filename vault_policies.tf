resource "vault_policy" "policy-edit" {
  name = "policy-edit"

  policy = <<EOT
path "sys/policy/*" {
  policy = "write"
}
EOT
}