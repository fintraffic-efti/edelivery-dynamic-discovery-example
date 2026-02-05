FROM eclipse-temurin:21 AS build

USER root

ADD https://github.com/nordic-institute/harmony-smp.git /tmp/harmony-smp

WORKDIR /tmp/harmony-smp
# Cache package directories to speed up local development when there are other changes to the layer
# "The cache for RUN instructions can be invalidated by using the --no-cache flag, for example docker build --no-cache."
# [https://docs.docker.com/reference/dockerfile/#cache-invalidation-for-run-instructions]
RUN --mount=type=cache,target=/root/.m2 --mount=type=cache,target=/root/.npm ./mvnw clean install -DskipTests -DskipITs

FROM tomcat:9-jre21-temurin

COPY --from=build /tmp/harmony-smp/smp-webapp/target/harmonysmp.war /usr/local/tomcat/webapps/

# Mysql driver is not included in war, add it manually.
# ADD supports only sha256 which was calculated manually
ADD --checksum=sha256:d77962877d010777cff997015da90ee689f0f4bb76848340e1488f2b83332af5 \
    https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar \
    /usr/local/tomcat/lib/
