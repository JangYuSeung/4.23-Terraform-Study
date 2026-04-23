# S3 버킷 생성
resource "aws_s3_bucket" "st8_ex_s3_bucket" {
    bucket = "st8-ex-s3-bucket"
    tags = { Name = "st8_ex_s3_bucket" }

    # 이 옵션을 추가하면 객체가 들어있어도 버킷 삭제 가능. => 실습만을 위해 사용
    force_destroy = true
}

# Bucket 버전 관리 설정
resource "aws_s3_bucket_versioning" "st8_ex_s3_bucket_versioning" {
    bucket = aws_s3_bucket.st8_ex_s3_bucket.id
    versioning_configuration {
        status = "Disabled" # Enabled | Disabled(비활성화) | Suspended(중지)
    }
}

# Bucket Access Control List (ACL) 설정
resource "aws_s3_bucket_public_access_block" "st8_ex_s3_bucket_access" {
    bucket = aws_s3_bucket.st8_ex_s3_bucket.id
    
    # 1. 새 퍼블릭 ACL 추가를 막을지 말지 설정.
    block_public_acls = false
    # 2. 기존에 설정된 모든 퍼블릭 ACL 무시할지 말지 설정.
    ignore_public_acls = false
    # 3. 버킷 정책을 통해 외부인이 접근하는 것을 차단할지 말지 설정.
    block_public_policy = false
    # 4. 퍼블릭 정책이 걸려 있는 버킷에 대한 익명 접근을 제한할지 말지 설정.
    restrict_public_buckets = false
}

# 정적 웹사이트 호스팅 활성화 (단, Bucket Access의 4가지 속성 모두 false로 설정해야 함)
resource "aws_s3_bucket_website_configuration" "st8_ex_s3_bucket_web_config" {
    bucket = aws_s3_bucket.st8_ex_s3_bucket.id

    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}

# 버킷 정책 설정 (모든 사용자에게 읽기 권한 부여)
resource "aws_s3_bucket_policy" "st8_ex_s3_bucket_policy" {
    bucket = aws_s3_bucket.st8_ex_s3_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "terraform"
                Principal = "*"
                Effect = "Allow"
                Action = [
                    "s3:GetObject" # 모든 사용자에게 객체 읽기 권한 부여
                ],
                Resource = "${aws_s3_bucket.st8_ex_s3_bucket.arn}/*" # 버킷 내 모든 객체에 대한 권한 부여
            }
        ]
    })
}