# EKS 클러스터의 kubeconfig 업데이트를 위한 null_resource
resource "null_resource" "update_kubeconfig" {
    # 노드 그룹이 생성 완료된 후 실행되도록 설정
    depends_on = [aws_eks_node_group.st8_node_group]

    # 로컬 명령 실행을 위한 provisioner
    # AWS CLI를 사용하여 kubeconfig 업데이트 명령 실행
    # 아래 command는 kubeconfig 파일을 업데이트하여 kubectl이 EKS 클러스터와 통신할 수 있도록 설정하는 명령
    # region과 cluster name에 다른 사람의 클러스터 정보를 넣으면, kubectl로 다른 사람의 클러스터에 접근 가능해짐!
    provisioner "local-exec" {
        # .name 대신 .id를 사용하여 Deprecated Warning 해결
        # command = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${aws_eks_cluster.st8_cluster.name}
        command = "aws eks update-kubeconfig --region ${data.aws_region.st8-region.name} --name ${aws_eks_cluster.st8_cluster.id}"
    }
}