# FROM adoptopenjdk/openjdk11:alpine-slim
FROM openjdk:17-alpine
ADD dms-service-webservice/target/dms-service-webservice-qa-1.0.0.0.jar dms-service-webservice-qa-1.0.0.0.jar

RUN apk update && apk --no-cache add curl \
    && apk add busybox-extras \
    && apk add --no-cache tzdata \
    && apk add ttf-dejavu
    
ENV TZ Asia/Singapore
EXPOSE 8080 
ENTRYPOINT ["java","-Dspring.profiles.active=qa,docker","-jar","/dms-service-webservice-qa-1.0.0.0.jar"]
