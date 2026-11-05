variable "name_prefix" {
  description = "Prefix used to name network resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
}
