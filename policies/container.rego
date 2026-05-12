package container

# Rule 1: Prevent privileged container execution
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Privileged container prevention: Container '%s' has privileged mode enabled. Privileged containers are not allowed for security reasons.", [container.name])
}

# Rule 2: Prevent privileged container execution - explicit false check
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.privileged == false
  msg := sprintf("Privileged container prevention: Container '%s' securityContext must explicitly set privileged to false.", [container.name])
}

# Rule 3: Prevent privilege escalation
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Privilege escalation prevention: Container '%s' has allowPrivilegeEscalation enabled. This is not allowed for security reasons.", [container.name])
}

# Rule 4: Enforce allowPrivilegeEscalation is false
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.allowPrivilegeEscalation == false
  msg := sprintf("Privilege escalation prevention: Container '%s' securityContext must explicitly set allowPrivilegeEscalation to false.", [container.name])
}
