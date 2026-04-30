# #####################################################
# 사용자 AMI를 이용한 시작 템플릿 생성
# =====================================================
resource "aws_launch_template" "st8_ex_LT" {
    # AMI 이미지: Amazon Linux 2023 중 EKS 지원 이미지이어야 함
    # => AWS콘솔-이미지 카탈로그 - "amazon-eks-node-al2023-x86_64-standard" 검색 후 이미지 ID를 아래 삽입
    image_id = "ami-0fd01939d29afc17e"
    name_prefix = "st8-ex-LT" # 인스턴스 이름 접두사
    instance_type = "t3.large" # EKS 인스턴스는 최소 medium 이상임!
    # key_name = "st8_terraform_test_key"

    vpc_security_group_ids = [
        data.aws_security_group.st8_http_SG.id,
        data.aws_security_group.st8_ssh_SG.id,
        data.aws_security_group.st8_eks_SG.id,
        # AWS의 EKS 마스터와의 통신을 위한 보안 그룹 정의
        # 아래 보안 그룹은 클러스터 생성과 함께 AWS에서 자동으로 생성하여 마스터에게 부여가 됨.
        aws_eks_cluster.st8_cluster.vpc_config[0].cluster_security_group_id
    ]

     # true: 새 버전이 생성될 때마다 최신 버전을 기본 버전으로 설정!
    update_default_version = true # false: 기본 버전을 수동으로 업데이트해야 함
    description = "Launch Template for EKS" # 템플릿 설명

    # user_data = filebase64("${path.module}/user_data.sh") # 인스턴스 시작 시 실행할 스크립트 (base64로 인코딩된 파일 경로)
    user_data = base64encode(<<-EOF
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${aws_eks_cluster.st8_cluster.name}
    apiServerEndpoint: ${aws_eks_cluster.st8_cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.st8_cluster.certificate_authority[0].data}
    cidr: ${aws_eks_cluster.st8_cluster.kubernetes_network_config[0].service_ipv4_cidr}
EOF
    )

    tag_specifications {
        resource_type = "instance" # 태그를 인스턴스에 적용하겠다
        tags = { Name = "st8-EKS-instance" }
    }

    tag_specifications {
      resource_type = "volume"
      tags = { Name = "st8-EKS-instance-vol" }
    }
}

# Node group 생성
resource "aws_eks_node_group" "st8_node_group" {
    cluster_name = aws_eks_cluster.st8_cluster.name
    node_group_name = "st8-node-group"
    node_role_arn = aws_iam_role.node_role.arn
    subnet_ids = data.aws_subnets.st8_subnet.ids

    # 노드 그룹의 인스턴스 수 설정
    scaling_config {
        desired_size = 2
        max_size = 3
        min_size = 1
    }

    # 시작 템플릿 설정
    launch_template {
        name = aws_launch_template.st8_ex_LT.name
        version = "$Latest" # 최신 버전 사용 <-> "$Default": 기본 버전 사용
    }

    # 종속성 문제로 인한 적용 순서 강제 지정
    # 노드 그룹이 클러스터와 IAM 역할에 의존하므로, 이들이 먼저 생성되도록 설정
    depends_on = [ aws_iam_role_policy_attachment.node_attachments]

}