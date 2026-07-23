variable "google_cert_name" {
  type = string
}

variable "google_sso_url" {
  type = string
}

variable "aqualog_auth_callback_url" {
  type    = string
  default = "http://localhost:8002/auth/callback"
}

variable "aqualog_test_token_callback_url" {
  type    = string
  default = "http://127.0.0.1:8400/callback"
}

variable "aqualog_app_url" {
  type    = string
  default = "http://localhost:8002"
}

variable "aqualog_client_id" {
  type    = string
}

variable "mail_send_host" {
  type = string
}
variable "mail_send_port" {
  type = number
}
variable "mail_send_username" {
  type = string
}
variable "mail_send_password" {
  type = string
}
variable "mail_send_from_address" {
  type = string
}
variable "mail_send_use_tls" {
  type = bool
}
variable "mail_send_use_ssl" {
  type = bool
}