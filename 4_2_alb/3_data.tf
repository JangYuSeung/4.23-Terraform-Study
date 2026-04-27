# data 블록은 리소스 생성이 아닌, AWS에서 정보를 가져오는 블록

data "aws_vpc" "st8_ex_vpc" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_vpc"]
    }
}

# Public Subnet 정보 => 서브넷이 3개이므로 aws_subnets로 복수형 사용
data "aws_subnets" "st8_ex_public_subnets" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_public1_subnet", "st8_ex_public2_subnet", "st8_ex_public3_subnet"]
    }
}

# Private Subnet 정보 => 서브넷이 3개이므로 aws_subnets로 복수형 사용
data "aws_subnets" "st8_ex_private_subnets" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_private1_subnet", "st8_ex_private2_subnet", "st8_ex_private3_subnet"]
    }
}

# ec2 인스턴스 보안 그룹 정보: http_SG
data "aws_security_group" "st8_ex_http_SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_http_SG"]
    }
}

# ec2 인스턴스 보안 그룹 정보: ssh_SG
data "aws_security_group" "st8_ex_ssh-SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_ssh-SG"]
    }
}

# ec2 인스턴스 보안 그룹 정보: fastapi_SG
data "aws_security_group" "st8_ex_fastapi-SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_fastapi-SG"]
    }
}

# ALB 보안 그룹 정보
data "aws_security_group" "st8_ex_alb_SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_alb_SG"]
    }
}

# 가용영역 정보
data "aws_availability_zones" "available" {
    state = "available" # 사용 가능한 가용영역 정보 가져오기
}