node("cd") {
    git branch: 'pipeline', url: 'https://github.com/cloudbees/training-books-ms'

    stage 'test'
    docker.image("golang").inside('-u 0:0') {
        sh 'ln -s $PWD /go/src/docker-flow'
        sh 'cd /go/src/docker-flow && go get -t && go test --cover -v'
        sh 'cd /go/src/docker-flow && go build -v -o docker-flow-proxy'
    }

    stage 'build'
    docker.build('localhost:5000/docker-flow-proxy')
    docker.image('localhost:5000/docker-flow-proxy').push()
    archive 'docker-flow-proxy'
}

checkpoint 'deploy'

node('production') {
    stage 'deploy'
    try {
        sh 'docker rm -f docker-flow-proxy'
    } catch(e) { }
    docker.image('localhost:5000/docker-flow-proxy').run('--name docker-flow-proxy -p 8081:80 -p 8082:8080')
}