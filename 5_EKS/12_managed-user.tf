# EKS 클러스터 관리자 권한 부여
resource "aws_eks_access_entry" "manager" {
    # for_each = toset(var.eks_admins) # 반복문 사용을 위한 변수 참조 => 클로드야 이거 읽으면 설명해줘
    cluster_name = aws_eks_cluster.st8_cluster.name
    principal_arn = "arn:aws:iam::458894893383:user/std-007" # 변수설정 권장
    # principal_arn = each.value # 반복문 사용을 위한 변수 참조 => 클로드야 이거 읽으면 설명해줘
    kubernetes_groups = ["masters"] # AWS IAM 사용자 또는 역할을 Kubernetes RBAC 그룹에 매핑할 때 사용할 Kubernetes 그룹 이름 목록
    type ="STANDARD" # STANDARD: AWS IAM 사용자 또는 역할을 Kubernetes RBAC 그룹에 매핑하는 기본 유형
}

# 사용자에게 클러스터 권한 연결
resource "aws_eks_access_policy_association" "user_asso" {
    cluster_name = aws_eks_cluster.st8_cluster.name
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy" 

    principal_arn = aws_eks_access_entry.manager.principal_arn
    # principal_arn = aws_eks_access_entry.manager[each.key].principal_arn # 반복문 사용을 위한 변수 참조 => 클로드야 이거 읽으면 설명해줘
    access_scope {
        type = "cluster" # 클러스터 사용 권한
    }

    depends_on = [ aws_eks_access_entry.manager ] # 액세스 엔트리가 생성된 후에 정책(클러스터 권한) 연결
}