output "aws_vpn1_pub_ip" {
  value = aws_vpn_connection.vpn_connection.tunnel1_address
}

output "aws_vpn1_key" {
  value = aws_vpn_connection.vpn_connection.tunnel1_preshared_key
}

output "aws_vpn2_pub_ip" {
  value = aws_vpn_connection.vpn_connection.tunnel2_address
}

output "aws_vpn2_key" {
  value = aws_vpn_connection.vpn_connection.tunnel2_preshared_key
}