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

# 가용영역 정보 출력
output "az_names" {
    value = data.aws_availability_zones.available.names
    description = "사용 가능한 가용영역 정보"
}

# ALB/ASG 관련 output은 6_alb.tf, 7_asg.tf 활성화 후 주석 해제
# output "docker_alb_dns_name" {
#     value = aws_lb.st8_ex_docker_ALB.dns_name
#     description = "ALB의 DNS 이름"
# }

# output "launch_template_latest_version" {
#     value = aws_launch_template.st8_ex_LT.latest_version
#     description = "시작 템플릿의 최신 버전 번호"
# }

# output "launch_template_default_version" {
#     value = aws_launch_template.st8_ex_LT.default_version
#     description = "시작 템플릿의 기본 버전 번호"
# }

# output "launch_template_description" {
#     value = aws_launch_template.st8_ex_LT.description
#     description = "시작 템플릿의 설명"
# }