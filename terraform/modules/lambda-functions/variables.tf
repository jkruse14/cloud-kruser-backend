variable "lambdas" {
  type = map(object({
    role_arn              = string
    function_name         = string
    filename              = string
    memory_size           = number
    timeout               = number
    environment_variables = map(string)
    layers                = optional(list(string))
    handler               = string
  }))
}

variable "name_prefix" {
  type = string
}

variable "common_layers" {
  type    = list(string)
  default = []
}
