# Use an official Apache Tomcat image as a base
FROM tomcat:9.0

# Copy the packaged WAR file into the webapps directory of Tomcat
COPY target/petclinic.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 (Tomcat's default port)
EXPOSE 8080

# ECS will provide everything, so we may not need port 8080 for tomcat.