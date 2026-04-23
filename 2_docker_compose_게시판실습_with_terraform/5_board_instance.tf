# SSH 키 페어 생성
resource "aws_key_pair" "st8_terraform_test_key" {
    key_name = "st8_terraform_test_key" # 키 페어 이름
    public_key = file("C:/Users/user/.ssh/st8_terraform_test_key.pub")
}

# EC2 인스턴스 생성
resource "aws_instance" "st8_board_instance" {
    ami = "ami-0aa31b568c1e8d622" # Amazon Linux2 AMI(하이데라바드 리전) / 콘솔-인스턴스 시작 창에서 확인 가능
    instance_type = "t3.micro" # 인스턴스 유형
    
    key_name = "st8_terraform_test_key" # SSH 키 페어

    # 네트워크 설정
    subnet_id = aws_subnet.st8_ex_public_subnets[0].id # 첫 번째 퍼블릭 서브넷에 EC2 인스턴스 배치
    associate_public_ip_address = true # 퍼블릭 IP 자동 할당 (public이니 필수)

    # 스토리지 설정: 루트 볼륨
    root_block_device {
        volume_size = 10 # 루트 볼륨 크기 (GB)
        volume_type = "gp3" # 볼륨 유형 (gp3: 범용 SSD)
        delete_on_termination = true # 인스턴스 종료 시 볼륨 삭제 여부
    }

    # 보안 그룹 설정: SSH와 HTTP 트래픽 허용
    vpc_security_group_ids = [
        aws_security_group.st8_ex_http_SG.id, # HTTP 트래픽 허용 SG
        aws_security_group.st8_ex_ssh-SG.id # SSH 트래픽 허용 SG
    ]

    # User Data 설정
    # ${path.module}: 현재 실행 중인 .tf 파일(5_board_instance.tf)이 위치한 디렉토리의 절대 경로를 자동으로 반환하는 테라폼의 내장 변수
    user_data = file("${path.module}/init-scripts-docker-compose.sh")
    user_data_replace_on_change = true # user_data 변경 시 인스턴스 자동 재생성
    
    # user_data = <<-EOF
    #     #!/bin/bash
    #     dnf update -y
    #     dnf install -y nginx

    #     systemctl enable nginx
    #     systemctl start nginx
    #     echo "<h1>Hello Nginx</h1>" > /usr/share/nginx/html/index.html
    # EOF

    tags = { Name = "st8_ex_instance" }
}