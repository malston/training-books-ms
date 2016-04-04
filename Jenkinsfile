node("cd") {
    def dir = pwd()
    sh "mkdir -p ${dir}/db"
    sh "chmod 0777 ${dir}/db"

    stage "pre-deployment tests"
    def tests = docker.image("localhost:5000/training-books-ms-tests")
    tests.pull()
    tests.inside("-v ${dir}/db:/data/db") {
        sh "./run_tests.sh"
    }

    stage "build"
    def service = docker.build "localhost:5000/training-books-ms"
    service.push()
    stash includes: "docker-compose*.yml", name: "docker-compose"
}
