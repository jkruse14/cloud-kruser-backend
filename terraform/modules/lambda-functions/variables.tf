variable "lambdas" {
  type = map(object({
    role_arn              = string
    filename              = string
    function_name         = string
    memory_size           = number
    timeout               = number
    environment_variables = map(string)
  }))
}