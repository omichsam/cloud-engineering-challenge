FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q
FROM eclipse-temurin:21-jre
COPY --from=build /src/target/library-1.jar /app.jar
EXPOSE 8080
CMD ["java","-jar","/app.jar"]
