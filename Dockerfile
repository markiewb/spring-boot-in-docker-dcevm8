# Example https://spring.io/guides/gs/spring-boot-docker/
#FROM openjdk:8-jdk-alpine

# https://github.com/HotswapProjects/hotswap-docklands
# https://github.com/HotswapProjects/hotswap-docklands/blob/master/hotswap-vm/Dockerfile
# https://github.com/anapsix/docker-alpine-java
FROM anapsix/alpine-java:8_jdk-dcevm    
VOLUME /tmp
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
# support external JAVA_OPTS, see open PR
# https://github.com/spring-guides/gs-spring-boot-docker/pull/55/commits/bca1a357d82549c76acb6d32aa00559f57d24e0d
ENV JAVA_OPTS=""
ENTRYPOINT exec java $JAVA_OPTS -cp app:app/lib/* com.example.springbootindocker.SpringBootInDockerApplication

# 1. build with
#    mvn clean package dockerfile:build -DskipTests
# 2. run with 
#    docker run --rm -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" -p 8080:8080 -p 5005:5005 --name testname testme/spring-boot-in-docker:latest