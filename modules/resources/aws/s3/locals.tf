locals {
  cleaned_relative_path         = replace(path.module,"../","")
  resource_path                 = replace(local.cleaned_relative_path,"^/+","")
}