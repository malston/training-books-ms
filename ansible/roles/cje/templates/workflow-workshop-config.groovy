node("cd") {
    git 'https://github.com/cloudbees/training-books-ms.git'
    def dir = pwd()
    sh "mkdir -p ${dir}/db"
    sh "chmod 0777 ${dir}/db"

    stage "pre-deployment tests"
    def tests = docker.image("10.100.198.200:5000/training-books-ms-tests")
    tests.pull()
    tests.inside("-v ${dir}/db:/data/db") {
        sh "./run_tests.sh"
    }

    stage "build"
    def service = docker.build "10.100.198.200:5000/training-books-ms"
    service.push()
    stash includes: "docker-compose*.yml", name: "docker-compose"
}
checkpoint "deploy"
node("production") {
    stage "deploy"
    input message: "Please confirm deployment to production", ok: "I confirm"
    unstash "docker-compose"
    def pull = [:]
    pull["service"] = {
        docker.image("10.100.198.200:5000/books-ms").pull()
    }
    pull["db"] = {
        docker.image("mongo").pull()
    }
    parallel pull
    sh "docker-compose -p books-ms up -d app"
    sh "curl http://10.100.198.200:8080/docker-traceability/submitContainerStatus \
        --data-urlencode inspectData=\"\$(docker inspect booksms_app_1)\""
    sleep 2
}
node("cd") {
    stage "post-deployment tests"
    def tests = docker.image("10.100.198.200:5000/training-books-ms-tests")
    tests.inside() {
        withEnv(["TEST_TYPE=integ", "DOMAIN=http://10.100.198.200:8081"]) {
            retry(1) {
                sh "./run_tests.sh"
            }
        }
    }
}