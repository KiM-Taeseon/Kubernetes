# 사용할 프로바이더의 소스데이터 정보
terraform {
required_version = ">= 1.0.0"
  required_providers {
    openstack = {
        source = "terraform-provider-openstack/openstack"
        version = "1.54.1"
    }
  }
}

# 위에서 지정한 프로바이더에 접속하기 위한 인증 정보, 인증 api 주소
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "test123"
  auth_url    = "http://211.183.3.10:5000/v3"
  region      = "RegionOne"
}