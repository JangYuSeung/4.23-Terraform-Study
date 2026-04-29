# Local 상수(변수) 정의 => 상수: 로컬 변수는 잘 변하지 않는다
# 반복되는 값을 한곳에 관리하여 유지보수를 쉽게
# 사용할 때 local로 접근: local.변수명
locals {
    vpc_name = "st8_EKS_vpc" # VPC 이름 태그 값
    subnet_ids = data.aws_subnets.st8_subnet.ids # 서브넷 ID 목록
}