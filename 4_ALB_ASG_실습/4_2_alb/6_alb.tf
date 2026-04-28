# 1_1. docker_main 대상그룹 생성(8080)
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

# 1_2. docker_main 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_main_TG_Attachment" {
    # 어느 대상 그룹에 등록할지 지정
    target_group_arn = aws_lb_target_group.st8_ex_docker_main_TG.arn # 위에서 생성한 대상의 그룹의 ARN
    target_id = aws_instance.st8_alb_instance.id # 생성한 인스턴스 ID로 등록
    port = 8080 # 대상그룹의 포트와 일치시켜야 함
}

# 3_1. docker_build 대상그룹 생성(8082)
resource "aws_lb_target_group" "st8_ex_docker_build_TG" {
    name = "st8-ex-docker-build-TG"
    port = 8082
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_docker_build_TG" }
}

# 3_2. docker_build 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_build_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_docker_build_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8082
}

# 4_1. docker_command 대상그룹 생성(8083)
resource "aws_lb_target_group" "st8_ex_docker_command_TG" {
    name = "st8-ex-docker-command-TG"
    port = 8083
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_docker_command_TG" }
}

# 4_2. docker_command 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_command_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_docker_command_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8083
}

# 5_1. docker_compose 대상그룹 생성(8084)
resource "aws_lb_target_group" "st8_ex_docker_compose_TG" {
    name = "st8-ex-docker-compose-TG"
    port = 8084
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_docker_compose_TG" }
}

# 5_2. docker_compose 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_compose_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_docker_compose_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8084
}

# 6_1. docker_swarm 대상그룹 생성(8085)
resource "aws_lb_target_group" "st8_ex_docker_swarm_TG" {
    name = "st8-ex-docker-swarm-TG"
    port = 8085
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_docker_swarm_TG" }
}

# 6_2. docker_swarm 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_swarm_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_docker_swarm_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8085
}

# 2_1. docker_install 대상그룹 생성(8081)
resource "aws_lb_target_group" "st8_ex_docker_install_TG" {
    name = "st8-ex-docker-install-TG"
    # 외부 - 중간(대상그룹) - 컨테이너라고 했을 때, 중간 포트(=컨테이너 입장에서 external 포트)
    port = 8081 # docker run -p 8081:80 
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
    tags = { Name = "st8_ex_docker_install_TG" }
}

# 2_2. docker_install 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_docker_install_TG_Attachment" {
    # 어느 대상 그룹에 등록할지 지정
    target_group_arn = aws_lb_target_group.st8_ex_docker_install_TG.arn # 위에서 생성한 대상의 그룹의 ARN
    target_id = aws_instance.st8_alb_instance.id # 생성한 인스턴스 ID로 등록
    port = 8081 # 대상그룹의 포트와 일치시켜야 함
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
# ==========================================================
resource "aws_lb_listener_rule" "install_path_install_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn # HTTPS 리스너에 규칙 추가
    priority = 10 # 기본 규칙보다 우선순위 높아야 함(낮은 숫자가 더 높은 우선순위)

    # Target Group 정의
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_docker_install_TG.arn # docker_install 대상 그룹으로 라우팅
    }

    # 경로 정의: value의 ,는 "또는"을 의미
    condition {
        path_pattern {
            values = ["/install", "/install/*"] # /install 또는 /install/로 시작하는 모든 경로에 대해 이 규칙 적용
        }
    }
}

resource "aws_lb_listener_rule" "build_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 20

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_docker_build_TG.arn
    }

    condition {
        path_pattern {
            values = ["/build", "/build/*"]
        }
    }
}

resource "aws_lb_listener_rule" "command_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 30

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_docker_command_TG.arn
    }

    condition {
        path_pattern {
            values = ["/command", "/command/*"]
        }
    }
}

resource "aws_lb_listener_rule" "compose_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 40

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_docker_compose_TG.arn
    }

    condition {
        path_pattern {
            values = ["/compose", "/compose/*"]
        }
    }
}

resource "aws_lb_listener_rule" "swarm_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 50

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_docker_swarm_TG.arn
    }

    condition {
        path_pattern {
            values = ["/swarm", "/swarm/*"]
        }
    }
}

# 7_1. kubernetes_fastapi 대상그룹 생성(8087)
resource "aws_lb_target_group" "st8_ex_kubernetes_fastapi_TG" {
    name = "st8-ex-kubernetes-fastapi-TG"
    port = 8087
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        # FastAPI(root_path="/kubernetes") 환경에서 /kubernetes 또는 /kubernetes/ 요청이
        # 환경에 따라 200/307/404 등을 반환할 수 있음. matcher를 200-399로 확장해
        # 리다이렉트도 healthy로 인정.
        path = "/kubernetes/"
        protocol = "HTTP"
        matcher = "200-399"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_kubernetes_fastapi_TG" }
}

# 7_2. kubernetes_fastapi 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_kubernetes_fastapi_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_kubernetes_fastapi_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8087
}

# 7_3. /kubernetes 경로 규칙
resource "aws_lb_listener_rule" "kubernetes_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 60

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_kubernetes_fastapi_TG.arn
    }

    condition {
        path_pattern {
            values = ["/kubernetes", "/kubernetes/*"]
        }
    }
}

# 8_1. board_nginx 대상그룹 생성(8088)
resource "aws_lb_target_group" "st8_ex_board_nginx_TG" {
    name = "st8-ex-board-nginx-TG"
    port = 8088
    protocol = "HTTP"
    vpc_id = data.aws_vpc.st8_ex_vpc.id

    slow_start = 30
    deregistration_delay = 30

    health_check {
        path = "/board"
        protocol = "HTTP"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 3
    }
    tags = { Name = "st8_ex_board_nginx_TG" }
}

# 8_2. board_nginx 대상그룹에 인스턴스 등록
resource "aws_lb_target_group_attachment" "st8_ex_board_nginx_TG_Attachment" {
    target_group_arn = aws_lb_target_group.st8_ex_board_nginx_TG.arn
    target_id = aws_instance.st8_alb_instance.id
    port = 8088
}

# 8_3. /board 경로 규칙
resource "aws_lb_listener_rule" "board_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 70

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_board_nginx_TG.arn
    }

    condition {
        path_pattern {
            values = ["/board", "/board/*"]
        }
    }
}

# 8_4. /api/board 경로 규칙 (list.html 내부에서 호출하는 백엔드 API)
# board-nginx의 location /api/board/ 가 board-fastapi로 proxy_pass 함.
resource "aws_lb_listener_rule" "board_api_path_rule" {
    listener_arn = aws_lb_listener.st8_ex_alb_https_listener.arn
    priority = 80

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.st8_ex_board_nginx_TG.arn
    }

    condition {
        path_pattern {
            values = ["/api/board", "/api/board/*"]
        }
    }
}