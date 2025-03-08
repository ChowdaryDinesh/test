
resource "aws_ecr_repository" "testrepo" {
  name                 = "testrepodi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}