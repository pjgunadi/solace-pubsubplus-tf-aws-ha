output "id" {
  description = "Keypair Name"
  value       = aws_key_pair.aws_public_key.id
}

output "public_key" {
  description = "Keypair Name"
  value       = aws_key_pair.aws_public_key.public_key
}
