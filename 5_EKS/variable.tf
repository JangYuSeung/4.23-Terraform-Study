variable "eks_admins" {
    type = list(string)
    # default = ["arn:aws:iam::458894893383:user/std-007"] # EKS 클러스터 관리자 권한을 부여할 AWS IAM 사용자 또는 역할의 ARN 목록
    default = []
}