# alb 보안 그룹 => http, https 인바운드 허용
resource "aws_security_group" "st8_ex_alb_SG" {
    name = "st8_ex_alb_SG"
    vpc_id = aws_vpc.st8_EKS_vpc.id # 보안 그룹은 VPC에 종속적이므로 VPC ID 필요
    description = "Allow HTTP and HTTPS traffic"

    ingress {
        # HTTP 인바운드 트래픽 허용
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 소스: Anywhere (모든 IP 주소에서 허용)
    }
    ingress {
        # HTTPS 인바운드 트래픽 허용
        from_port = 443 
        to_port = 443 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # 아웃바운드 트래픽 허용 (기본값은 모든 트래픽 허용)
    egress {
        from_port = 0 # 모든 포트 허용
        to_port = 0 # 모든 포트 허용
        protocol = "-1" # 모든 프로토콜 허용
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소로 허용
    }
    tags = { Name = "st8_ex_alb_SG" }
}

# EC2 보안 그룹 => SSH 인바운드 허용
resource "aws_security_group" "st8_ex_ssh-SG" {
    name = "st8_ex_ssh-SG"
    vpc_id = aws_vpc.st8_EKS_vpc.id
    description = "Allow SSH traffic"
    
    # SSH 인바운드 트래픽 허용
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소에서 허용
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { Name = "st8_ex_ssh-SG" }
}

# EC2 보안 그룹 => HTTP 인바운드 허용 (ALB에서만 허용)
resource "aws_security_group" "st8_ex_http_SG" {
    name = "st8_ex_http_SG"
    vpc_id = aws_vpc.st8_EKS_vpc.id
    description = "Allow HTTP traffic"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = { Name = "st8_ex_http_SG" }
}

# 보안 그룹 규칙 생성 후 위 보안 그룹에 적용
resource "aws_security_group_rule" "allow_alb_to_http" {
    # 보안 규칙 유형: ingress (80)
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"

    # 위 인바운드 보안 규칙을 http 보안 그룹에 적용
    security_group_id = aws_security_group.st8_ex_http_SG.id
    # ALB 보안 그룹에서 온 트래픽만 허용
    source_security_group_id = aws_security_group.st8_ex_alb_SG.id # 소스: ALB 보안 그룹에서만 허용
}

# =========================================================
# 컨트롤 플레인으로부터 kubelet 통신 허용
resource "aws_security_group" "eks_nodes_sg" {
    name = "st8-eks-node-communication-SG"
    vpc_id = aws_vpc.st8_EKS_vpc.id
    description = "Security group for eks worker nodes"
    
    # 1. 노드 간 통신 허용 (All traffic)
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1" # 모든 프로토콜 허용
        self = true # 같은 보안 그룹에 속한 리소스 간 통신 허용
        description = "Allow nodes to communicate with each other"
    }

    # 2. 컨트롤 플레인에서 kubelet 통신 허용 (TCP 10250)
    ingress {
        from_port = 10250
        to_port = 10250
        protocol = "tcp"
        # 컨트롤 플레인에서 오는 트래픽 허용: EKS 관리형 노드 그룹은 aws_eks_cluster 리소스의 security_group_ids에 이 보안 그룹을 추가하여 통신 허용
        description = "Allow control plane to communicate with kubelet"

    # 보안을 위해 클러스터 보안 그룹만 허용하도록 설정 가능
	# security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_primary_security_group_id]
    }
    tags = { Name = "st8-eks-node-SG" }
}