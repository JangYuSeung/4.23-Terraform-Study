# #######################################################
# 클러스터 마스터 역할 및 정책
# =========================================================

# 클러스터 역할(IAM Role) 생성
resource "aws_iam_role" "cluster_role" {
    name = "st8_eks_cluster_role"
    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17",
            Statement = [
                {
                    Action = "sts:AssumeRole",
                    Effect = "Allow",
                    Principal = { Service = "eks.amazonaws.com" }
                }
            ]
        }
    )
}

# 클러스터 역할(IAM Role)에 EKS 클러스터 정책(Policy) 연결
resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.cluster_role.name
}

# #######################################################
# 워커노드의 역할 및 정책
# eks가 아니라 ec2: 노드 역할은 EC2 서비스가 맡음 <-> 클러스터 역할은 EKS 서비스가 맡음 
# =========================================================
resource "aws_iam_role" "node_role" {
    name = "st8-node-role"
    assume_role_policy = jsonencode(
        {
            Version = "2012-10-17",
            Statement = [
                {
                    Action = "sts:AssumeRole",
                    Effect = "Allow",
                    Principal = { Service = "ec2.amazonaws.com" }
                }
            ]
        }
    )
}

# 반복문 사용을 통한 정책 부여를 위해 로컬 변수 선언
locals {
    node_policies = [ # toset: 중복 제거된 집합(Set)(list)으로 변환. 중복된 ARN 값이 있더라도 하나만 남김ㄴ
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
}
# 노드 역할(IAM Role)에 여러 정책(Policy) 연결
resource "aws_iam_role_policy_attachment" "node_attachments" {
    for_each = toset(local.node_policies)
    policy_arn = each.value # each.value: for_each로 반복되는 각 요소의 값(ARN)을 참조
    role = aws_iam_role.node_role.name
}