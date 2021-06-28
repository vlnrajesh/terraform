resource "aws_instance" "bastion_server" {
  ami               =   "${var.ami_id}"
  instance_type     =   "${var.instance_type}"
}