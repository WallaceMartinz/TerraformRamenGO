module "net" {
    source = "../network"
}

resource "aws_key_pair" "generated_key"{
    key_name = var.key_pair_name
    public_key = file("ramengo_rsa.pem.pub")
}

resource "aws_instance" "ec2-publica" {
    ami                         = var.ami
    availability_zone           = var.a_zone
    instance_type               = var.inst_type
    ebs_block_device {
        device_name             = "/dev/sda1"
        volume_size             = 30
        volume_type             = "standard"
    }
    key_name                    = aws_key_pair.generated_key.key_name
    subnet_id                   = module.net.subnet_public_id
    associate_public_ip_address = true
    tags = {
        Name                    = "ramengo"
    }
}


