FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package

FROM tomcat:9.0-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /src/target/bank.war /usr/local/tomcat/webapps/ROOT.war
ENV CATALINA_OPTS="-Dfile.encoding=UTF-8"
EXPOSE 8080
