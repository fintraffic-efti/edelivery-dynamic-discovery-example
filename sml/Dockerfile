FROM tomcat:10-jre21-temurin

# NOTE: war name will be context path part in the url of the UI
ADD --checksum=sha256:c90a6694a5750e7de78cfb2be404c010e8218a7f0929fb34cf39e232b1c1696f \
    https://ec.europa.eu/digital-building-blocks/artifact/repository/public/eu/europa/ec/bdmsl/bdmsl-webapp/5.0.1/bdmsl-webapp-5.0.1.war \
    /usr/local/tomcat/webapps/edelivery-sml.war

# Mysql driver is not included in war, add it manually.
# ADD supports only sha256 which was calculated manually
ADD --checksum=sha256:d77962877d010777cff997015da90ee689f0f4bb76848340e1488f2b83332af5 \
    https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar \
    /usr/local/tomcat/lib/

# unzip needed in some of our scripts
RUN apt-get update && apt-get install -y unzip
