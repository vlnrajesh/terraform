

module "postgres_deploy" {
  source              = "../../modules/kreuzwerker/docker/postgres/"
}
module "jenkins_master_deploy" {
  source              = "../../modules/kreuzwerker/docker/jenkins_master"
}

module "nginx_deploy" {
  source             = "../../modules/kreuzwerker/docker/nginx"
}