# #####################################################
# 사용자 AMI를 이용한 시작 템플릿 생성
# =====================================================
resource "aws_launch_template" "st8_ex_LT" {
    image_id = aws_ami_from_instance.st8_ex_ami.id
    name_prefix = "st8-ex-LT" # 인스턴스 이름 접두사
    instance_type = "t3.micro"
    key_name = "st8_terraform_test_key"

    vpc_security_group_ids = [
        data.aws_security_group.st8_ex_http_SG.id,
        data.aws_security_group.st8_ex_ssh-SG.id,
        data.aws_security_group.st8_ex_fastapi-SG.id
    ]

     # true: 새 버전이 생성될 때마다 최신 버전을 기본 버전으로 설정
    update_default_version = true # false: 기본 버전을 수동으로 업데이트해야 함
    description = "Launch Template for ASG using custom AMI" # 버전 단위의 설명(꼭 달아주기)

    tag_specifications {
        resource_type = "instance" # 태그를 인스턴스에 적용하겠다
        tags = { Name = "st8-ex-ASG-instance" }
    }

    tag_specifications {
      resource_type = "volume"
      tags = { Name = "st8-ex-ASG-instance-vol" }
    }
}

# #####################################################
# 오토스케일 그룹 생성
# =====================================================
resource "aws_autoscaling_group" "st8_ex_ASG" {
    name = "st8-ex-ASG"

    desired_capacity = 1
    max_size = 3
    min_size = 1
    
    launch_template {
        id = aws_launch_template.st8_ex_LT.id
        version = "$Default" # $Default: 기본 템플릿 버전 사용, $Latest: 최신 템플릿 버전 사용
    }

    # 위치할 서브넷 지정
    vpc_zone_identifier = [
        data.aws_subnets.st8_ex_private_subnets.ids[0], # 첫 번째 프라이빗 서브넷
        data.aws_subnets.st8_ex_private_subnets.ids[1], # 두 번째 프라이빗 서브넷,
        data.aws_subnets.st8_ex_private_subnets.ids[2]  # 세 번째 프라이빗 서브넷
    ]

    # ASG의 인스턴스가 종료될 때 기존 연결 유지 시간
    lifecycle {
        ignore_changes = [desired_capacity] # desired_capacity 변경 시 ASG 인스턴스 종료 방지
    }

    # ALB와 연동하기 위한 Target Group ARN 지정
    target_group_arns = [
        aws_lb_target_group.st8_ex_docker_main_TG.arn, # main Target Group ARN
        aws_lb_target_group.st8_ex_docker_install_TG.arn # install Target Group ARN
    ]

    # 헬스 체크
    health_check_type = "ELB" # EC2: 인스턴스 상태 체크 사용, ELB: 로드밸런서 헬스 체크
    health_check_grace_period = 300 # 인스턴스 시작 후 초기화 대기시간 = 헬스체크를 시작하기 전에 기다리는 시간 (초 단위)
}
# -----------------------------------------------------
# 오토스케일 그룹 인스턴스 조정 기준
resource "aws_autoscaling_policy" "st8_ex_ASG_policy" {
    name = "st8-ex-ASG-policy"
    autoscaling_group_name = aws_autoscaling_group.st8_ex_ASG.name
    # 대상 추적 정책 유형
    # TargetTrackingScaling: ASG의 특정 지표가 목표값을 유지하도록 인스턴스 수를 자동으로 조정하는 정책 유형
    # StepScaling: ASG의 지표가 특정 임계값을 초과하거나 미만일 때 인스턴스 수를 단계적으로 조정하는 정책 유형
    # SimpleScaling: ASG의 지표가 특정 임계값을 초과하거나 미만일 때 인스턴스 수를 단일 단계로 조정하는 정책 유형
    # PredictiveScaling: ASG의 지표를 예측하여 인스턴스 수를 사전에 조정하는 정책 유형
    policy_type = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ASGAverageCPUUtilization" # ASG의 평균 CPU 사용률을 지표로 사용
        }
        target_value = 50.0 # CPU 사용률이 50%를 유지하도록 ASG 인스턴스 수 조정(50% ~ 70% 권장)
    }
}
