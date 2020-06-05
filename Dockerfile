# Setup the Server
FROM openjdk:8-jdk-alpine as builder

WORKDIR /usr/src/app

COPY ./ ./

RUN ./gradlew bootjar


# Run the Server
FROM openjdk:8-jre-alpine

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

CMD java -jar app.jar
