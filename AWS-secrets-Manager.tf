resource "aws_secretsmanager_secret" "postgres-dev-rds" {
  name = "rdsadmin"
}

resource "aws_secretsmanager_secret_version" "postgres-dev-rds" {
  secret_id     = aws_secretsmanager_secret.postgres-dev-rds.id
  secret_string = "ChangeThisPasswordN0w!"
}