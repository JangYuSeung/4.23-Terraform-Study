# 현재 리전 정보
data "aws_regions" "current" {
    
}

# 현재 리전의 가용영역 정보
data "aws_availability_zones" "available" {
    state = "available" # 사용 가능한 가용영역만 조회
}