def serviceName = "training-books-ms"
 def registry = "10.100.198.200:5000"
 def flow

 node("cd") {
     git "https://github.com/cloudbees/${serviceName}.git"
     flow = load "/data/scripts/pipeline-common.groovy"
     flow.runPreDeploymentTests(serviceName, registry)
     flow.build(serviceName, registry)
 }
 checkpoint "deploy"
 node("cd") {
     flow.deploy(serviceName, registry)
     flow.runPostDeploymentTests(serviceName, registry, "http://10.100.198.200:8081")
 }