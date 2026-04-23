# 테라폼에게 AWS 프로바이더 6.0 버전 이상을 쓸 거라고 알려주는 설정 파일.
# AWS를 사용할 거면 aws cli를 사용해야 하고, google을 사용할 거면 gcloud cli를 사용해야 한다.

terraform { # 테라폼 버전과 프로바이더 설정
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 6.0" # 테라폼 6.0~<7.0 
      }
    }

    # required_providers {
    #   google = {
    #     source = "hashicorp/google"
    #     version = "~> 4.0" # 테라폼 4.0~<5.0
    #   }
    # }
}