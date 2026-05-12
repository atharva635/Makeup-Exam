package deployment

# Rule 1: Prevent insecure deployments - image must be specified
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.image == ""
  msg := "Insecure deployment prevented: Container image must be specified (empty image not allowed)"
}

# Rule 2: Enforce image version tagging - disallow :latest tag
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  image := container.image
  endswith(image, ":latest")
  msg := sprintf("Image version tagging enforcement: Image '%s' uses :latest tag which is not allowed. Use specific version tags (e.g., :1.0.0, :v1.2.3)", [image])
}

# Rule 3: Enforce image version tagging - image must have a tag
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  image := container.image
  not contains(image, ":")
  msg := sprintf("Image version tagging enforcement: Image '%s' must have an explicit version tag (e.g., image:1.0.0). Untagged images are not allowed.", [image])
}
