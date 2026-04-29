# 데이터 소스 = AWS 리소스에 대한 정보를 조회할 때 사용하는 블록
# 핵심: 리소스 중 "원하는 정보를 지정해서" 조회 가능 

# 현재 리전 정보
# provider에 region="ap-south-2"이므로, data.aws_region.st8-region.name의 값은 "ap-south-2"가 됨
data "aws_region" "st8-region" {
    
}

# 현재 리전의 가용영역 정보
data "aws_availability_zones" "available" {
    state = "available" # 사용 가능한 가용영역만 조회
}

# VPC 정보 
data "aws_vpc" "st8-vpc" {
    filter {
        name = "tag:Name"
        values = [local.vpc_name] # 로컬 변수 vpc_name 사용 = "st8_EKS_vpc"
    }
    depends_on = [aws_vpc.st8_EKS_vpc] # VPC가 생성된 후에 데이터 조회하도록 의존성 설정
}

# 서브넷 정보
data "aws_subnets" "st8_subnet" {
    # 어느 VPC의 서브넷인지 지정
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.st8-vpc.id] # VPC ID를 사용하여 서브넷 조회
    }
    # 내부 ELB용 서브넷 조회
    # kubernetes.io/role/internal-elb=1
    filter {
        name = "tag:kubernetes.io/role/internal-elb"
        values = ["1"] 
    }
}

# EKS 인스턴스에 연결할 보안 그룹: http
data "aws_security_group" "st8_http_SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_http_SG"] # 보안 그룹 이름 태그로 조회
    }
    depends_on = [aws_security_group.st8_ex_http_SG] # SG 생성 후에 조회
}

# EKS 인스턴스에 연결할 보안 그룹: ssh
data "aws_security_group" "st8_ssh_SG" {
    filter {
        name = "tag:Name"
        values = ["st8_ex_ssh-SG"] # 보안 그룹 이름 태그로 조회
    }
    depends_on = [aws_security_group.st8_ex_ssh-SG] # SG 생성 후에 조회
}

# EKS 인스턴스에 연결할 보안 그룹: EKS 노드용 보안 그룹
data "aws_security_group" "st8_eks_SG" {
    filter {
        name = "tag:Name"
        values = ["st8-eks-node-SG"] # 보안 그룹 이름 태그로 조회
    }
    depends_on = [aws_security_group.eks_nodes_sg] # SG 생성 후에 조회
}