variable "authentik_url" {
  type        = string
  description = "The URL of the authentik instance"
  default     = "http://localhost:8000"
}

variable "authentik_token" {
  type        = string
  description = "The API token for the authentik instance"
}

variable "aqualog_auth_callback_url" {
  type    = string
  default = "http://localhost:8002/auth/callback"
}

variable "aqualog_test_token_callback_url" {
  type    = string
  default = "http://127.0.0.1:8400/callback"
}

variable "aqualog_app_title" {
  type    = string
  default = "AquaLog"
}

variable "aqualog_app_domain" {
  type    = string
  default = "localhost:8002"
}

variable "aqualog_app_url" {
  type    = string
  default = "http://localhost:8002"
}

variable "aqualog_client_id" {
  type    = string
  default = "aqualog"
}

variable "mail_send_host" {
  type    = string
  default = ""
}

variable "mail_send_port" {
  type    = number
  default = 25
}

variable "mail_send_username" {
  type    = string
  default = ""
}

variable "mail_send_password" {
  type    = string
  default = ""
}

variable "mail_send_from_address" {
  type    = string
  default = ""
}

variable "mail_send_use_tls" {
  type    = bool
  default = false
}

variable "mail_send_use_ssl" {
  type    = bool
  default = false
}