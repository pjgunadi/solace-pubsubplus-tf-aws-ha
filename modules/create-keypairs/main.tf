resource "tls_private_key" "ssh" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "cat > ${var.solace_keypair}.crt <<EOL\n${tls_private_key.ssh.private_key_pem}\nEOL"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${var.solace_keypair}.crt"
  }
}

resource "aws_key_pair" "aws_public_key" {
  key_name   = var.solace_keypair
  public_key = tls_private_key.ssh.public_key_openssh
  tags = var.common_tags
}
