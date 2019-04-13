Example for a REST-enabled Spring Boot application in a Docker container with Oracle JDK 8 and DCEVM enabled. 

# Steps for local/remote development

1. Build the image with 
    
        mvn clean package dockerfile:build
    
    (... and push it to a Docker registry, if you need to deploy it outside your local machine)

2. Start the Docker image with JDPA debugging enabled 
    
        docker run --rm \
        -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
        -p 127.0.0.1:8080:8080 -p 127.0.0.1:5005:5005 \
        --name testname \
        testme/spring-boot-in-docker:latest

3. Attach the debugger of your IDE to port 5005

4. Coding
    1. Browse to http://localhost:8080/
    1. Change some code and invoke "Reload changed classes" (Intellij IDEA)
        * &check; extracting/introducing methods/fields works
        * &cross; introducing new classes doesn't work (The Spring Boot classloader doesn't find the new class. Perhaps an issue with DECVM 8? Checkout mounting the current classes as described below.)
        * &cross; changing superclass/implementing interfaces doesn't work (DCEVM-feature) 
    1. Repeat

# Keeping the classes

After a restart of your application all your changes to classes are lost. So start the application by using the current compiled classes from your local machine. This also allows you to introduce new classes, which was not possible before.

Start the Docker image with JDPA debugging enabled and mount the current classes from `target/classes/com` into the container: 
    
    docker run --rm \
    -v $(pwd)/target/classes/com:/app/com \
    -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
    -p 127.0.0.1:8080:8080 -p 127.0.0.1:5005:5005 \
    --name testname \
    testme/spring-boot-in-docker:latest

# Resources
* [Official Quickstart for Spring Boot REST](https://spring.io/guides/gs/rest-service/)
* [Dockerfile `hotswap-docklands:hotswap-vm`](https://github.com/HotswapProjects/hotswap-docklands/blob/master/hotswap-vm/Dockerfile)
* [Dockerfile `docker-alpine-java`](https://github.com/anapsix/docker-alpine-java)
