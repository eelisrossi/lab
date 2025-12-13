terraform {
  backend "local" {
    path = "../../state/production.tfstate"
  }
}
