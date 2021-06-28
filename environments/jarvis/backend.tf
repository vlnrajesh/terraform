terraform {
  backend "local" {
    path    = "../../state/${path.cwd}/terraform.tfstate"
  }
}