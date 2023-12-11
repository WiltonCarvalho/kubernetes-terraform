FROM eclipse-temurin:11-jdk AS builder
WORKDIR workspace
COPY . .
ARG JAR_FILE=build/libs/*.jar
ARG GRADLE_USER_HOME=/tmp/build_cache/gradle
RUN --mount=type=cache,target=/tmp/build_cache/gradle \
    set -ex \
    && chmod +x gradlew \
    && ./gradlew clean build -x jar -i \
    && java -Djarmode=layertools -jar $JAR_FILE extract
FROM eclipse-temurin:11-jre
USER 999:0
WORKDIR workspace
COPY --from=builder workspace/dependencies/ ./
COPY --from=builder workspace/spring-boot-loader/ ./
COPY --from=builder workspace/snapshot-dependencies/ ./
COPY --from=builder workspace/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
