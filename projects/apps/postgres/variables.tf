variable "postgres_container_name" {
  type =string
  default = "postgres"
}
variable "postgres_image_name" {
  type = string
  default ="postgres"
}
variable "postgres_image_tag" {
  type = string
  default = "13-alpine"
}
variable "postgres_db_port" {
  type = number
  default = 5432
}
variable "pgdata_container_path" {
  type = string
  default ="/var/lib/postgresql/data"
}
variable "pgdata_local_path" {
  type = string
  default = "/opt/data/postgres/data"
}
variable "postgres_username" {
  type = string
  default = "postgres"
}
variable "postgres_password" {
  type = string
  default = "postgres"
}