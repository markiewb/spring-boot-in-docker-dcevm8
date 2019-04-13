Example for a REST-enabled Spring Boot application in a Docker container with Oracle JDK 8 and DCEVM+Hotswap-Agent enabled. 

# Prerequisites
1. Build the [Docker image](Dockerfile) with 
    
        mvn clean package dockerfile:build
    
    (... and push it to a Docker registry, if you need to deploy it outside your local machine)

# 1. Steps for local/remote development

Features:
* &check; extracting/introducing methods/fields works
* &cross; changes to classes are kept after restart
* &cross; introducing new classes doesn't work (The Spring Boot classloader doesn't find the new class. Perhaps an issue with DECVM 8? Checkout mounting the current classes as described below.)
* &cross; changing superclass/implementing interfaces doesn't work (DCEVM-feature) 


Steps:
1. Start the Docker image with JDPA debugging enabled 
    
        docker run --rm \
        -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
        -p 127.0.0.1:8080:8080 -p 127.0.0.1:5005:5005 \
        --name testname \
        testme/spring-boot-in-docker-dcevm8:latest

2. Attach the debugger of your IDE to port 5005

3. Coding
    1. Change some code and invoke "Reload changed classes" (which includes compiling) (Intellij IDEA)
    1. Browse to http://localhost:8080/ to see the changes. 
    1. Repeat

# 2. Keeping the classes (local only)

After a restart of your application all your changes to classes are lost. So start the application by using the current compiled classes from your local machine. This also allows you to introduce new classes, which was not possible before.

Features:
* &check; extracting/introducing methods/fields works
* &check; changes to classes are kept after restart
* &check; introducing new classes works. (Because of mounting the current classes as described below.)
* &cross; changing superclass/implementing interfaces doesn't work (DCEVM-feature) 


Steps:
1. Start the Docker image with JDPA debugging enabled and mount the current classes from `target/classes/com` into the container: 
    
        docker run --rm \
        -v $(pwd)/target/classes/com:/app/com \
        -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005" \
        -p 127.0.0.1:8080:8080 -p 127.0.0.1:5005:5005 \
        --name testname \
        testme/spring-boot-in-docker-dcevm8:latest
    
2. Attach the debugger of your IDE to port 5005

3. Coding
    1. Change some code and invoke "Reload changed classes" (which includes compiling) (Intellij IDEA)
    1. Browse to http://localhost:8080/ to see the changes. 
    1. Repeat
    
# 3. Keeping the classes and reload the Spring context after configuration changes (local only)

Using the Hotswap-Agent allows to reload configuration of frameworks like Spring and Hibernate, when changing the source code. 

1. Start the Docker image with JDPA debugging and the hotswap-agent enabled. Local current classes are mounted into the container too:
 
        docker run --rm \
        -v $(pwd)/target/classes/com:/app/com \
        -e "JAVA_OPTS=-XXaltjvm=dcevm -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -javaagent:/opt/hotswap-agent/hotswap-agent.jar -Dextra.class.path=/extra_class_path" \
        -p 127.0.0.1:8080:8080 -p 127.0.0.1:5005:5005 \
        --name testname \
        testme/spring-boot-in-docker-dcevm8:latest

2. Coding
    1. Change some code (extract methods, change @RequestMapping) and invoke "Compile" (manually or using Save Actions)
        * Because of the setting `autoHotswap=true` in [hotswap-agent.properties](src/main/resources/hotswap-agent.properties) the HotSwap-Agent will replace the recompiled classes automatically even WITHOUT an attached debugger. In the background the 
        * You can still attach the debugger. Then you'll have to "Reload changed classes"
    1. Browse to http://localhost:8080/ to see the changes. 
    1. Repeat

See description at <https://github.com/HotswapProjects/hotswap-docklands>

## Troubleshooting
IMO Hotswap-Agent seems not so stable, but it works for simple use cases. 

If you encounter errors, 
* disable the plugins for the Hotswap-Agent and file an issue at <https://github.com/HotswapProjects/HotswapAgent>
* read the documentation 

Note that the automatic restart of `spring-boot-devtools` is disabled, when the [HotSwap-Agent is detected](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-devtools/src/main/java/org/springframework/boot/devtools/restart/AgentReloader.java#L35). In newer Spring Boot version the message “[Restart disabled due to an agent-based reloader being active](https://github.com/spring-projects/spring-boot/pull/14807)” will be displayed.

# Resources
* [Official Quickstart for Spring Boot REST](https://spring.io/guides/gs/rest-service/)
* [Dockerfile `hotswap-docklands:hotswap-vm`](https://github.com/HotswapProjects/hotswap-docklands/blob/master/hotswap-vm/Dockerfile)
* [Dockerfile `docker-alpine-java`](https://github.com/anapsix/docker-alpine-java)
* [HotSwap-Agent](https://github.com/HotswapProjects/HotswapAgent)
* [DCEVM](https://github.com/dcevm/dcevm)
