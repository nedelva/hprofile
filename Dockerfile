# -----------------------------
# Build stage
# -----------------------------
FROM maven:3.9.11-eclipse-temurin-11 AS build

WORKDIR /app

# Copy Maven descriptor first to leverage Docker cache
COPY pom.xml .

# Download dependencies
RUN mvn -B dependency:go-offline

# Copy the rest of the project
COPY . .

# Build the application
RUN mvn -B clean package -DskipTests

# -----------------------------
# Runtime stage
# -----------------------------
FROM tomcat:9.0-jre11-temurin

LABEL project="Vprofile"
LABEL author="Imran"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build \
    /app/target/vprofile-v2.war \
    /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
