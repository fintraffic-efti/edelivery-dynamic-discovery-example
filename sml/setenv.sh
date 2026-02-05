#!/bin/sh

# https://docs.edelivery.tech.ec.europa.eu/domisml/5.0/#sml_installation

export SML_HIBERNATE_DIALECT=org.hibernate.dialect.MySQLDialect
export SML_JDBC_DRIVER=com.mysql.cj.jdbc.Driver
export SML_JDBC_URL="jdbc:mysql://sml-db:3306/harmony_sml?allowPublicKeyRetrieval=true"
export SML_JDBC_USER=harmony_sml
export SML_JDBC_PASSWORD=local-pwd-123
