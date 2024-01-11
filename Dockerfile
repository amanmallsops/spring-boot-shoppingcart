FROM fabric8/java-alpine-openjdk8-jre

WORKDIR /application

RUN apk --no-cache add maven openjdk8

COPY . /application
RUN mvn clean package -DskipTests=true

ENV JAR_FILE_NAME=shoppingcart-ui-0.0.1-SNAPSHOT-exec.jar
RUN cp /application/target/$JAR_FILE_NAME app.jar

ENV JAVA_APP_JAR=app.jar

EXPOSE ${PORT_8787} ${PORT_8080}

ENV JAVA_OPTS="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8787,suspend=n"
RUN sh -c 'touch /app.jar'

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=docker -jar $JAVA_APP_JAR"]

CMD ["/bin/bash", "-c", "
      while ! (nc -z config-server 8888 && nc -z vault 8200); do sleep 5; echo 'Waiting for vault and config-server services to start-up...'; done;
      java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8787,suspend=n -jar -Dspring.profiles.active=docker $JAVA_APP_JAR
      "]
