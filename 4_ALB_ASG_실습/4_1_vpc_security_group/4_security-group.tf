# alb 보안 그룹 => http, https 인바운드 허용
resource "aws_security_group" "st8_ex_alb_SG" {
    name = "st8_ex_alb_SG"
    vpc_id = aws_vpc.st8_ex_vpc.id # 보안 그룹은 VPC에 종속적이므로 VPC ID 필요
    description = "Allow HTTP and HTTPS traffic"

    ingress {
        # HTTP 인바운드 트래픽 허용
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 소스: Anywhere (모든 IP 주소에서 허용)
    }

    ingress {
        # HTTPS 인바운드 트래픽 허용
        from_port = 443 
        to_port = 443 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # 아웃바운드 트래픽 허용 (기본값은 모든 트래픽 허용)
    egress {
        from_port = 0 # 모든 포트 허용
        to_port = 0 # 모든 포트 허용
        protocol = "-1" # 모든 프로토콜 허용
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소로 허용
    }

    tags = { Name = "st8_ex_alb_SG" }
}

# EC2 보안 그룹 => SSH 인바운드 허용
resource "aws_security_group" "st8_ex_ssh-SG" {
    name = "st8_ex_ssh-SG"
    vpc_id = aws_vpc.st8_ex_vpc.id
    description = "Allow SSH traffic"
    
    # SSH 인바운드 트래픽 허용
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소에서 허용
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "st8_ex_ssh-SG" }
}

# EC2 보안 그룹 => HTTP 인바운드 허용 (ALB에서만 허용)
resource "aws_security_group" "st8_ex_http_SG" {
    name = "st8_ex_http_SG"
    vpc_id = aws_vpc.st8_ex_vpc.id
    description = "Allow HTTP traffic"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "st8_ex_http_SG" }
}

# 보안 그룹 규칙 생성
resource "aws_security_group_rule" "allow_alb_to_http" {
    # 보안 규칙 유형: 인바운드 트래픽 허용
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"

    # 위 인바운드 보안 규칙을 http 보안 그룹에 적용
    security_group_id = aws_security_group.st8_ex_http_SG.id
    # ALB 보안 그룹에서 온 트래픽만 허용
    source_security_group_id = aws_security_group.st8_ex_alb_SG.id # 소스: ALB 보안 그룹에서만 허용
}

# fastapi 보안그룹 추가 (나머지 보안 그룹 리소스는 4_1_vpc_security_group.tf에 있음)
# EC2 보안 그룹 => fastapi 인바운드 허용
resource "aws_security_group" "st8_ex_fastapi-SG" {
    name = "st8_ex_fastapi-SG"
    vpc_id = aws_vpc.st8_ex_vpc.id
    description = "Allow fastapi traffic"
    
    # fastapi 인바운드 트래픽 허용
    ingress {
        from_port = 8086
        to_port = 8086
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소에서 허용
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "st8_ex_fastapi-SG" }
}