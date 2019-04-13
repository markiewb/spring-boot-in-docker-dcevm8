# Example https://spring.io/guides/gs/spring-boot-docker/
#FROM openjdk:8-jdk-alpine

# https://github.com/HotswapProjects/hotswap-docklands
# https://github.com/HotswapProjects/hotswap-docklands/blob/master/hotswap-vm/Dockerfile
# https://github.com/anapsix/docker-alpine-java
# hotswapagent/hotswap-vm extends anapsix/alpine-java:8_jdk-dcevm and includes hotswap-agent
FROM hotswapagent/hotswap-vm
VOLUME /tmp
RUN apk -U upgrade \
    && apk add curl \
    && apk add unzip \
    && mkdir -p /opt/hotswap-agent/ \
    && curl -L -o /opt/hotswap-agent/hotswap-agent.jar "https://github.com/HotswapProjects/HotswapAgent/releases/download/1.3.1-SNAPSHOT/hotswap-agent-1.3.1-SNAPSHOT.jar"
    
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
# support external JAVA_OPTS, see open PR
# https://github.com/spring-guides/gs-spring-boot-docker/pull/55/commits/bca1a357d82549c76acb6d32aa00559f57d24e0d
ENV JAVA_OPTS=""
ENTRYPOINT exec java $JAVA_OPTS -cp app:app/lib/* com.example.springbootindocker.SpringBootInDockerApplication