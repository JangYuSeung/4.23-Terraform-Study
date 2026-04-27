# 인스턴스 생성 및 보안 그룹 규칙 추가 및 AMI 생성

# 보안 그룹 규칙 추가: ALB에서 인스턴스로의 HTTP 트래픽 허용
resource "aws_security_group_rule" "st8_ex_http_SG" {
    # 8080~8086 포트 범위에서 TCP 프로토콜로 인바운드 트래픽 허용
    type = "ingress"
    from_port = 8080
    to_port = 8086
    protocol = "tcp"
    
    # 위 규칙을 http 보안 그룹에 적용
    security_group_id = data.aws_security_group.st8_ex_http_SG.id
    # 위 규칙의 소스는 ALB 보안 그룹에서만 허용
    source_security_group_id = data.aws_security_group.st8_ex_alb_SG.id
}

# 첫번째 존의 private subnet에 인스턴스 생성하기
resource "aws_instance" "st8_alb_instance" {
    ami = "ami-0aa31b568c1e8d622" # Amazon Linux 2 AMI
    instance_type = "t3.micro"

    key_name = "st8_terraform_test_key" # SSH 키 페어

    subnet_id = data.aws_subnets.st8_ex_private_subnets.ids[0] # 첫 번째 프라이빗 서브넷에 인스턴스 생성
    associate_public_ip_address = false # 퍼블릭 IP 비활성화 (프라이빗 서브넷이므로)

    # 스토리지 설정: 루트 볼륨
    root_block_device {
        volume_size = 10 # 루트 볼륨 크기 (GB)
        volume_type = "gp3" # 볼륨 유형 (gp3: 범용 SSD)
        delete_on_termination = true # 인스턴스 종료 시 볼륨 삭제 여부
    }

    # 보안 그룹 설정: SSH와 HTTP 트래픽 허용
    vpc_security_group_ids = [
        data.aws_security_group.st8_ex_http_SG.id,
        data.aws_security_group.st8_ex_ssh-SG.id,
        data.aws_security_group.st8_ex_fastapi-SG.id # fastapi 보안 그룹 추가
    ]

    # User Data 설정
    # ${path.module}: 현재 테라폼 모듈의 경로를 나타내는 변수.
    user_data = file("${path.module}/user-data.sh") 
    user_data_replace_on_change = true # user_data 변경 시 인스턴스 자동 재생성

    tags = { Name = "st8_alb_instance" }
}

# SSH 키 페어 생성
resource "aws_key_pair" "st8_terraform_test_key" {
    key_name = "st8_terraform_test_key" # 키 페어 이름
    public_key = file("C:/Users/user/.ssh/st8_terraform_test_key.pub")
}

# ########################################################################
# <AMI 인스턴스 생성>
# 참고: terraform apply로 현재 인스턴스로 이미지(AMI) 한번 생성한 이후에, 
# 인스턴스 내용 수정해서 다시 apply 하면, 이미지(AMI)도 재생성될까?
# => source_instance_id로 인스턴스를 참조하기 때문에, 인스턴스가 교체(replace)되느냐 아니냐에 따라 달라짐
#
# 1. AMI 재생성: 인스턴스가 destroy -> create되면 instance_id가 바뀌어 AMI 재생성됨
# (참고): 아래가 바뀌면 인스턴스 교체 발생
# # ami            = "ami-xxxxxxx"   # AMI 변경
# instance_type  = "t3.small"      # 인스턴스 타입 변경
# subnet_id      = ...             # 서브넷 변경
# user_data      = ...             # user_data 변경 (user_data_replace_on_change = true 이므로)
#
# 2. AMI 재생성 X: 인스턴스 업데이트
# (참고): 아래가 바뀌어도 인스턴스 교체가 아닌 업데이트 발생
# tags                   = { Name = "new-name" }   # 태그 변경
# vpc_security_group_ids = [...]                   # 보안그룹 변경
# key_name               = "new-key"              # 키페어 변경
# ========================================================================
resource "aws_ami_from_instance" "st8_ex_ami" {
    name = "st8-ex-ami"
    # AMI를 생성할 인스턴스 정의
    source_instance_id = aws_instance.st8_alb_instance.id

    # AMI 생성 시 인스턴스 재부팅 여부 설정
    # true: 인스턴스를 종료하지 않고 AMI 생성
    # default(false): 인스턴스를 일시적으로 종료하여 AMI 생성
    snapshot_without_reboot = false

    tags = { Name = "st8_ex_ami" }
}