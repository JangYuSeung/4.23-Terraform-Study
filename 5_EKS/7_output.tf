# 출력: vpc_id = 요구값
output "vpc_id" {
    value = data.aws_vpc.st8-vpc.id
}

# 출력: current_region = 요구값
output "current_region" {
    value = data.aws_region.st8-region.region
}

# 출력: 가용 영역 이름
output "availablity_zones" {
    description = "현재 리전의 가용영역 목록"
    value = data.aws_availability_zones.available.names
}

output "subnet_ids" {
    value = local.subnet_ids
}