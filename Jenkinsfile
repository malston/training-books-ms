def serviceName = "training-books-ms"
def registry = "10.100.198.200:5000"

node("cd") {
    git "https://github.com/cloudbees/${serviceName}.git"

    def flow = load "/data/scripts/workflow-common.groovy"
    flow.runPreDeploymentTests(serviceName, registry)
    flow.build(serviceName, registry)
}
node("production") {
    flow.deploy(serviceName, registry)
}
node("cd") {
    flow.runPostDeploymentTests(servieName, registry, "DOMAIN=http://10.100.198.200:8081")
}