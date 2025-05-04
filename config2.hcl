api_addr = "https://vault2.example.com:8200"
cluster_addr = "https://vault2.example.com:8201"
cluster_name = "vault-test"
disable_mlock = true
ui = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/etc/vault/tls/example.com/server.crt"
  tls_key_file  = "/etc/vault/tls/example.com/server.key"
  tls_client_ca_file = "/etc/vault/tls/ca/self_ca.crt"
}

backend "raft" {
  path = "/opt/vault/data"
  node_id = "vault2"

  retry_join {
    leader_tls_servername   = "vault1.example.com"
    leader_api_addr         = "https://vault1.example.com:8200"
    leader_ca_cert_file     = "/etc/vault/tls/ca/self_ca.crt"
    leader_client_cert_file = "/etc/vault/tls/example.com/server.crt"
    leader_client_key_file  = "/etc/vault/tls/example.com/server.key"
  }

  retry_join {
    leader_tls_servername   = "vault3.example.com"
    leader_api_addr         = "https://vault3.example.com:8200"
    leader_ca_cert_file     = "/etc/vault/tls/ca/self_ca.crt"
    leader_client_cert_file = "/etc/vault/tls/example.com/server.crt"
    leader_client_key_file  = "/etc/vault/tls/example.com/server.key"
  }
 
}
