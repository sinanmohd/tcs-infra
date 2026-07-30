variable "endpoint" {
  description = "SigNoz endpoint"
  type        = string
  default     = "https://signoz.bud.studio"
}

variable "api_key" {
  description = "SigNoz API Key from Settings -> API Keys"
  type        = string
  default     = null
}

variable "alert_channels" {
  description = "SigNoz Notification Channels from Settings -> Notification Channels"
  type        = list(string)
  default     = ["Slack"]
}
