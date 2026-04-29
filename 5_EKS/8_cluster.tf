# EKS 클러스터 생성
resource "aws_eks_cluster" "st8_cluster" {
    name = "st8-cluster"
    role_arn = aws_iam_role.cluster_role.arn

    # 워커노드가 위치할 서브넷 아이디 목록
    vpc_config {
        # subnet_ids = ["서브넷1ID", "서브넷2ID"]s
        # subnet_ids = data.aws_subnets.st8_subnet.ids 
        subnet_ids = local.subnet_ids
    }


    # 생성자 권한 부여
    access_config {
        # EKS API 서버에 대한 인증 모드 설정:
        # API_AND_CONFIG_MAP (API 서버와 ConfigMap을 모두 사용)

        authentication_mode = "API_AND_CONFIG_MAP"

        # EKS 클러스터 생성자에게 관리자 권한 부여 여부 설정:
        # true로 설정하면 클러스터 생성자(IAM 사용자 또는 역할)에 관리자 권한이 부여됨
        bootstrap_cluster_creator_admin_permissions = true
    }

    # # 클러스터 역할에 정책 연결 후에 클러스터 생성
    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy_attachment
    ]
}
