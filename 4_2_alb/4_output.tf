# output 블록은 테라폼이 AWS에서 가져온 정보를 출력하는 블록
output "vpc_id" {
    value = data.aws_vpc.st8_ex_vpc.id
}

output "public_subnet" {
    value = data.aws_subnets.st8_ex_public_subnets.ids[0] # 3개의 퍼블릭 서브넷 중 첫 번째 서브넷의 ID 출력
}

output "private_subnet" {
    value = data.aws_subnets.st8_ex_private_subnets.ids[0]  # 3개의 프라이빗 서브넷 중 첫 번째 서브넷의 ID 출력
}

output "st8_ex_http_SG" {
    value = data.aws_security_group.st8_ex_http_SG.id
}

output "az_names" {
    value = data.aws_availability_zones.available.names
    description = "사용 가능한 가용영역 정보"
}