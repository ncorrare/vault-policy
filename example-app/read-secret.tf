resource "vault_policy" "exampleapp" {
  name = "example-read-secret"

  policy = <<EOT
path "secret/example" {
  policy = "read"
}
EOT
}