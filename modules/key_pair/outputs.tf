output "key_pair_key_name" {
  description = "The key pair name."
  value       = aws_key_pair.key_pair.key_name
}

output "key_pair_key_pair_id" {
  description = "The key pair ID."
  value       = aws_key_pair.key_pair.id
}

output "key_pair_fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
  value       = aws_key_pair.key_pair.fingerprint
}

output "tls_private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = false
}