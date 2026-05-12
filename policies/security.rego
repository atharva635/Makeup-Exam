package security

# Rule 1: Restrict root user execution - Pod level
deny[msg] {
  input.kind == "Deployment"
  pod_context := input.spec.template.spec.securityContext
  pod_context.runAsNonRoot != true
  msg := "Root user execution prevention (Pod level): Pod securityContext must have runAsNonRoot set to true"
}

# Rule 2: Restrict root user execution - Container level
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container_context := container.securityContext
  container_context.runAsNonRoot != true
  msg := sprintf("Root user execution prevention (Container level): Container '%s' securityContext must have runAsNonRoot set to true", [container.name])
}

# Rule 3: Enforce runAsUser is set to non-zero (not root)
deny[msg] {
  input.kind == "Deployment"
  pod_context := input.spec.template.spec.securityContext
  pod_context.runAsUser == 0
  msg := "Root user execution prevention: Pod cannot run with UID 0 (root). Set runAsUser to a non-zero value."
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container_context := container.securityContext
  container_context.runAsUser == 0
  msg := sprintf("Root user execution prevention: Container '%s' cannot run with UID 0 (root). Set runAsUser to a non-zero value.", [container.name])
}
