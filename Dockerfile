FROM alpine:latest AS stage1
WORKDIR /app
RUN apk update && apk add git
RUN git clone https://github.com/shubhamkumar177/tomcatsettings.git
FROM maven:3.8.7-eclipse-temurin-11-focal AS stage2
WORKDIR /app 
COPY ./core ./core
COPY ./web ./web
COPY pom.xml pom.xml
RUN mvn -f /app/pom.xml clean install
FROM tomcat:latest
RUN cp -r /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY --from=stage1 /app/tomcatsettings/tomcat-users.xml /usr/local/tomcat/conf
COPY --from=stage1 /app/tomcatsettings/context.xml /usr/local/tomcat/webapps/manager/META-INF/
COPY --from=stage2 /app/web/target/*.war /usr/local/tomcat/webapps
