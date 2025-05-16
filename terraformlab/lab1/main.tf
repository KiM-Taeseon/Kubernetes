# key-pair 등록하기
resource "openstack_compute_keypair_v2" "keypair2" {
  name       = "testkey2"
  public_key = file("/root/terraformlab/lab1/testkey2.pub")
}

# 인스턴스 생성하기
resource "openstack_compute_instance_v2" "basic" {
  name = "ubuntu"
  image_id = "c44d26ea-4266-4c3f-b7fe-608ef87a6e69"
  flavor_id = "2"
  key_pair = openstack_compute_keypair_v2.keypair2.name
  security_groups = [openstack_networking_secgroup_v2.cirros_sg.name]
  

  network {
    name = "mynet"
  }
  user_data = <<-EOF
          #!/bin/bash
          touch test.txt
          sudo apt update
          sudo apt install -y nginx
          EOF

  lifecycle {
    create_before_destroy = true      # 생성 후 기존 인스턴스 삭제
  }
}


resource "terraform_data" "apply1" {
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("/root/terraformlab/lab1/testkey2")
    # private_key = file("/root/terraformlab/lab1/testkey2")
    host = openstack_networking_floatingip_v2.fip_1.address
  }


  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo '<h1> hello </h1> | sudo tee /var/www/html/index.html"
    ]
  }
}
  

  # ssh를 통한 connection
  # 설치후 로컬에서 원격 인스턴스에 ssh로 접곳하여 명령실행
  # remote-exe : 인스턴스에서 실행 (inline, script(scripts))




# 인스턴스 사설 주소 = 매핑 = 공인주소(floating ip)
# extnet 에서 공인주소 하나를 발행(인스턴스와 연결을 아직 아님)
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "extnet"
}

# 위에서 발행한 공인주소를 특정 인스턴스(cirros1) 와 매핑
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address # 공인주소
  instance_id = openstack_compute_instance_v2.basic.id # 어떤 인스턴스의
  fixed_ip    = openstack_compute_instance_v2.basic.network.0.fixed_ip_v4 # 어떤 사설주소(NIC)와 매핑
}

# 결과 확인
output "공인IP" {
  value       = openstack_networking_floatingip_v2.fip_1.address
}