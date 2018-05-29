FROM golang:alpine3.7

ENV DOCKER_VERSION=17.05.0-ce \
    DOCKER_COMPOSE_VERSION=1.18.0 \
    ENTRYKIT_VERSION=0.4.0

WORKDIR /

# Install Docker and Docker Compose
RUN apk --update --no-cache \
    add curl device-mapper py-pip iptables git openssh make && \
    rm -rf /var/cache/apk/* && \
    curl https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz | tar zx && \
    mv /docker/* /bin/ && chmod +x /bin/docker* && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}

#RUN apk --update --no-cache add curl device-mapper py-pip iptables make
#RUN rm -rf /var/cache/apk/*
#RUN curl https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz | tar zx
#RUN mv /docker/* /bin/ && chmod +x /bin/docker*
#RUN pip install docker-compose==${DOCKER_COMPOSE_VERSION}

# Install entrykit
RUN curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx && \
    chmod +x entrykit && \
    mv entrykit /bin/entrykit && \
    entrykit --symlink

# Include useful functions to start/stop docker daemon in garden-runc containers in Concourse CI.
# Example: source /docker-lib.sh && start_docker
COPY docker-lib.sh /docker-lib.sh

WORKDIR $GOPATH

RUN go get github.com/golang/mock/mockgen && \
    go get github.com/golang/dep/cmd/dep && \
    go get github.com/axw/gocov/gocov && \
    go get gopkg.in/matm/v1/gocov-html

ENTRYPOINT [ \
	"switch", \
		"shell=/bin/sh", "--", \
	"codep", \
		"/bin/docker daemon" \
]
