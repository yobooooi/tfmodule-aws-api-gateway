locals { 
  default_tags = {
    "Owner"       = var.team
    "ManagedBy"   = "terraform"
    "Environment" = var.environment
    "Backup"      = "false"
    "Status"      = "active"
  }
}