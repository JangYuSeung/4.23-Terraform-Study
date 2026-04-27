# vpc-network.tf

#######################################################
# VPC 구성
# =====================================================
resource "aws_vpc" "st8_ex_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true # VPC 내에서 DNS 호스트 이름 활성화: default(false)
  enable_dns_support = true # VPC에서 DNS 확인 활성화: default(true)
  
  tags = { Name = "st8_ex_vpc" }
}

#######################################################
# Public Subnet 구성 (반복문으로 3개 생성)
# =====================================================
resource "aws_subnet" "st8_ex_public_subnets" {
    count = 3 # 반복: 3개의 퍼블릭 서브넷 생성 / count는 첫 라인에 작성해야 함
    vpc_id = aws_vpc.st8_ex_vpc.id # 위에서 생성한 VPC의 ID
    # 
    cidr_block = "10.0.${count.index + 1}.0/24" # 큰 따옴표 안에서 ${}는 변수나 표현식 삽입을 의미 / count.index=0,1,2 순으로 증가
    # availability_zone = "ap-south-2a"
    # availability_zone = data.aws_availability_zones.available.names[count.index] # data는 AWS에서 정보를 가져오는 블록)
    availability_zone = ["ap-south-2a", "ap-south-2b", "ap-south-2c"][count.index] # count.index는 0부터 시작하는 인덱스 번호로, 각 반복에서 증가하며, 0,1,2는 각각 ap-south-2a, ap-south-2b, ap-south-2c를 의미 (data. 블록은 AWS에서 정보를 가져옴)

    map_public_ip_on_launch = true # 퍼블릭 IP 자동 할당: default(false)
    enable_resource_name_dns_a_record_on_launch = true # 서브넷에 리소스 이름 DNS A 레코드 생성 활성화: default(false)

    tags = { Name = "st8_ex_public${count.index + 1}_subnet" }
}


#######################################################
# Private Subnet 구성 (반복문으로 3개 생성)
# =====================================================
resource "aws_subnet" "st8_ex_private_subnets" {
    count=3 # 반복: 3개의 프라이빗 서브넷 생성 / count는 첫 라인에 작성해야 함
    vpc_id = aws_vpc.st8_ex_vpc.id
    cidr_block = "10.0.${count.index + 10}.0/24"
    # availability_zone = "ap-south-2a"
    availability_zone = ["ap-south-2a", "ap-south-2b", "ap-south-2c"][count.index] # count.index=0,1,2 = ap-south-2a, ap-south-2b, ap-south-2c
    
    tags = { Name = "st8_ex_private${count.index + 1}_subnet" }
}


#######################################################
# Internet Gateway 구성
# =====================================================
resource "aws_internet_gateway" "st8_ex_igw" {
    vpc_id = aws_vpc.st8_ex_vpc.id # 위에서 생성한 VPC의 ID
    tags = { Name = "st8_ex_igw" }
}

#######################################################
# NAT Gateway 구성
# =====================================================
# 1. Elastic IP 생성
resource "aws_eip" "st8_ex_NAT_EIP" {
    domain = "vpc" # VPC용 탄력적 IP 주소 생성
    tags = { Name = "st8_ex_NAT_EIP" }
}

# 2. NAT Gateway 생성
resource "aws_nat_gateway" "st8_ex_nat_gw" {
    allocation_id = aws_eip.st8_ex_NAT_EIP.id # 위에서 생성한 EIP의 ID
    subnet_id = aws_subnet.st8_ex_public_subnets[0].id # NAT GW가 위치할 퍼블릭 서브넷의 ID
    # IGW 생성이 완료된 후 NAT GW 생성
    depends_on = [ aws_internet_gateway.st8_ex_igw ] # 주의: id가 아님
    
    tags = { Name = "st8_ex_nat_gw"}
}


#########################################################
# Public 라우팅 테이블 구성
# =========================================================
# 라우팅 테이블 생성 => vpc 지정 및 라우팅만 설정
resource "aws_route_table" "st8_ex_public_RT" {
    vpc_id = aws_vpc.st8_ex_vpc.id # 위에서 생성한 VPC의 ID

    route {
        # 인터넷으로 라우팅하는 기본 경로 설정
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.st8_ex_igw.id # 위에서 생성한 IGW의 ID
    }
    tags = { Name = "st8_ex_public_RT" }

}

# Public 라우팅 테이블과 서브넷 연결
resource "aws_route_table_association" "st8_ex_public2a_RT_association" {
    count=3 # 반복: 라우팅 테이블을 3개의 퍼블릭 서브넷과 연결
    route_table_id = aws_route_table.st8_ex_public_RT.id # 서브넷과 연결할 RT ID
    subnet_id = aws_subnet.st8_ex_public_subnets[count.index].id # RT와 연결할 서브넷의 ID 
}

#########################################################
# Private 라우팅 테이블 구성
# =========================================================
resource "aws_route_table" "st8_ex_private_RT" {
    vpc_id = aws_vpc.st8_ex_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.st8_ex_nat_gw.id # 위에서 생성한 NAT GW의 ID
    }
    tags = { Name = "st8_ex_private_RT" }
}

# Private 라우팅 테이블과 서브넷 연결
resource "aws_route_table_association" "st8_ex_private2a_RT_association" {
    count          = 3 # 반복: 라우팅 테이블을 3개의 프라이빗 서브넷과 연결
    route_table_id = aws_route_table.st8_ex_private_RT.id # 서브넷과 연결할 RT ID
    subnet_id      = aws_subnet.st8_ex_private_subnets[count.index].id # RT와 연결할 서브넷의 ID
}
