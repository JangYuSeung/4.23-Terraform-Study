resource "aws_security_group_rule" "st8_ex_http_SG" {
    # 8080~8085 포트 범위에서 TCP 프로토콜로 인바운드 트래픽 허용
    type = "ingress"
    from_port = 8080
    to_port = 8085
    protocol = "tcp"
    
    # 위 규칙을 http 보안 그룹에 적용
    security_group_id = data.aws_security_group.st8_ex_http_SG.id
    # 위 규칙의 소스는 ALB 보안 그룹에서만 허용
    source_security_group_id = data.aws_security_group.st8_ex_alb_SG.id
}

# 첫번째 존의 public subnet에 인스턴스 생성하기
resource "aws_instance" "st8_ex_instance" {
    ami = "ami-0aa31b568c1e8d622" # Amazon Linux 2 AMI
    instance_type = "t3.micro"

    key_name = "st8_terraform_test_key" # SSH 키 페어

    subnet_id = data.aws_subnets.st8_ex_public_subnets.ids[0] # 첫 번째 퍼블릭 서브넷에 인스턴스 생성
    associate_public_ip_address = true # 퍼블릭 IP 자동 할당 (public이니 필수)

    # 스토리지 설정: 루트 볼륨
    root_block_device {
        volume_size = 10 # 루트 볼륨 크기 (GB)
        volume_type = "gp3" # 볼륨 유형 (gp3: 범용 SSD)
        delete_on_termination = true # 인스턴스 종료 시 볼륨 삭제 여부
    }

    # 보안 그룹 설정: SSH와 HTTP 트래픽 허용
    vpc_security_group_ids = [
        data.aws_security_group.st8_ex_http_SG.id,
        data.aws_security_group.st8_ex_ssh-SG.id
    ]

    tags = { Name = "st8_ex_instance" }
}

# SSH 키 페어 생성
resource "aws_key_pair" "st8_terraform_test_key" {
    key_name = "st8_terraform_test_key" # 키 페어 이름
    public_key = file("C:/Users/user/.ssh/st8_terraform_test_key.pub")
}