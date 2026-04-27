# 1. 대상 그룹 
resource "aws_lb_target_group" "st8_ex_docker_main_TG" {
    name = "st8-ex-docker-main-TG"
    # 외부 - 중간(대상그룹) - 컨테이너라고 했을 때, 중간 포트(=컨테이너 입장에서 external 포트)
    port = 8080 # docker run -p 8080:80 
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    # 인스턴스가 처음 시작하여 접속 시 비율을 점진적으로 증가할 여유 시간(선택)
    # 30초로 설정하여, 인스턴스가 시작된 후 30초 동안은 트래픽이 점진적으로 증가하도록 합니다.
    slow_start = 30 # 초
    # 인스턴스 종료 시, 기존 연결 유지 시간(선택)
    deregistration_delay = 30 # 초

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30 # "간격"= 30초마다 헬스체크
        timeout = 5 # 5초 동안 응답이 없으면 헬스체크 실패로 간주
        healthy_threshold = 2 # 2번 연속 헬스체크 성공 시 healthy로 간주
        unhealthy_threshold = 3 # 3번 연속 헬스체크 실패 시 unhealthy로 간주
    }

    tags = { Name = "st8_ex_docker_main_TG" }
}


# 2. 대상 그룹 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_main_TG_Attachment" {
    # 어느 대상 그룹에 등록할지 지정
    target_group_arn = aws_lb_target_group.st8_ex_docker_main_TG.arn # 위에서 생성한 대상의 그룹의 ARN
    target_id = aws_instance.st8_alb_instance.id # 생성한 인스턴스 ID로 등록
    port = 8080 # 대상그룹의 포트와 일치시켜야 함
}

# 3. ALB 생성
resource "aws_lb" "st8_ex_docker_ALB" {
    name = "st8-ex-docker-ALB"
    internal = false # 인터넷에서 접근 가능하도록 퍼블릭 ALB로 생성(인터넷 경계)
    load_balancer_type = "application" # ALB 유형 지정

    # 아래 지정된 서브넷이 속한 vpc를 자동으로 인식하기 때문에 vpc_id는 생략 가능

    security_groups = [data.aws_security_group.st8_ex_alb_SG.id] # ALB 보안 그룹 지정
    # ALB가 배치될 서브넷 지정 (2개 이상 권장)
    subnets = [
        data.aws_subnets.st8_ex_public_subnets.ids[0], # 첫 번째 퍼블릭 서브넷
        data.aws_subnets.st8_ex_public_subnets.ids[1], # 두 번째 퍼블릭 서브넷
        data.aws_subnets.st8_ex_public_subnets.ids[2]  # 세 번째 퍼블릭 서브넷
    ]

    tags = { Name = "st8_ex_docker_ALB" }
}
# 4. ALB 리스너 생성 (HTTPS: 443 포트)
resource "aws_lb_listener" "st8_ex_alb_https_listener" {
    load_balancer_arn = aws_lb.st8_ex_docker_ALB.arn # 위에서 생성한 ALB의 ARN
    port = 443 # ALB가 수신할 포트 (HTTPS)
    protocol = "HTTPS" # 리스너 프로토콜 (HTTPS)

    ssl_policy = "ELBSecurityPolicy-2016-08" # SSL 정책 지정 (예시: ELBSecurityPolicy-2016-08)
    certificate_arn = "arn:aws:acm:ap-south-2:458894893383:certificate/4a3b25f2-62f0-4f4c-8a6b-9ed3a44e31e2" # ACM에서 발급받은 SSL 인증서 ARN

    default_action {
    type = "forward" # 기본 액션: 요청을 대상 그룹으로 전달
    target_group_arn = aws_lb_target_group.st8_ex_docker_main_TG.arn # 타겟그룹의 ARN
    }
    tags = { Name = "st8_ex_alb_https_listener" }
}

# 4. ALB 리스너 생성 (HTTP: 80 포트)
resource "aws_lb_listener" "st8_ex_alb_http_listener" {
    load_balancer_arn = aws_lb.st8_ex_docker_ALB.arn # 위에서 생성한 ALB의 ARN
    port = 80 # ALB가 수신할 포트 (HTTP)
    protocol = "HTTP" # 리스너 프로토콜 (HTTP)

    default_action {
    type = "redirect" # 기본 액션: HTTP 요청을 HTTPS로 리디렉션

    # 리디렉션 설정: HTTP 요청을 HTTPS로 리디렉션하도록 설정
    redirect {
        protocol ="HTTPS" # 리디렉션할 프로토콜
        port = "443"
        status_code = "HTTP_301" # 리디렉션 상태 코드 (301 - 영구 이동됨)
       }
    }
    tags = { Name = "st8_ex_alb_http_listener" }
}

# 5. ALB 리스너 규칙 생성 (기본 규칙: 모든 요청을 대상 그룹으로 라우팅)