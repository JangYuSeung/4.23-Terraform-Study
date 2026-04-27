# provider.tf
# AWS 프로바이더 설정 파일

provider "aws" {
    region = "ap-south-2" # AWS CLI 환경설정 값이 우선됨

    # 기본 태그 설정: 테라폼으로 생성한 모든 리소스에 자동으로 태그를 추가
    default_tags {
      tags = {
        Project = "MSP06-Solution-Architect"
        Owner = "st8" 
        ManageBy = "Terraform" # Terraform으로 관리되는 리소스임을 나타내는 태그
      }
    }
}