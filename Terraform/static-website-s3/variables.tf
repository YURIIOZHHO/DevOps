variable "project_region" {
  description = "project region"
  type = string
  default = "eu-central-1"
}

variable "bucket_name" {
  description = "name of the bucket"
  type = string
  default = "website20112025.com"
}

# variable "domain_name" {
#   description = "name of the domain"
#   type = string
#   default = "website20112025.com"
# }

variable "version_of_policy" {
  description = "version of policy"
  type = string
  default = "2012-10-17"
}

variable "name_of_the_index_file" {
  description = "name of the index file"
  type = string
  default = "index.html"
}

variable "name_of_the_js_file" {
  description = "name of the js file"
  type = string
  default = "main.js"
}

variable "name_of_the_css_file" {
  description = "name of the css file"
  type = string
  default = "style.css"
}