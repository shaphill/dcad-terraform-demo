user = {
  username = "ADMIN"
  password = "PASSWORD"
  url      = "HOSTNAME"
}

vrf = "demo_vrf"
bridge_domains = {
  "web_bd" = {
    name    = "web_bd"
    gateway = "10.16.1.254/24"
  }
  "app_bd" = {
    name    = "app_bd"
    gateway = "10.16.2.254/24"
  }
  "db_bd" = {
    name    = "db_bd"
    gateway = "10.16.3.254/24"
  }
}

filters = {
  "web_app_filter" = {
    name    = "web_app_filter"
    dest    = "5000"
    ether_t = "ip"
    prot    = "tcp"
  }
  "app_db_filter" = {
    name    = "app_db_filter"
    dest    = "1433"
    ether_t = "ip"
    prot    = "tcp"
  }
}

contracts = {
  "web_app_contract" = {
    contract = "web_app_contract"
    subject  = "web_app_filter"
  }
  "app_db_contract" = {
    contract = "app_db_contract"
    subject  = "app_db_filter"
  }
}

ap = "demo_ap"

epgs = {
  "web" = {
    name = "web"
    bd   = "web_bd"
    contracts = {
      "consumer" = {
        name = "web_app_contract"
        type = "consumer"
      }
    }
  }
  "app" = {
    name = "app"
    bd   = "app_bd"
    contracts = {
      "provider" = {
        name = "web_app_contract"
        type = "provider"
      }
      "consumer" = {
        name = "app_db_contract"
        type = "consumer"
      }
    }
  }
  "db" = {
    name = "db"
    bd   = "db_bd"
    contracts = {
      "provider" = {
        name = "app_db_contract"
        type = "provider"
      }
    }
  }
}
