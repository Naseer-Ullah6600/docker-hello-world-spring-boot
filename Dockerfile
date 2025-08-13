# Maven build container 
FROM maven:3.8.5-openjdk-11 AS maven_build

COPY pom.xml /tmp/
COPY src /tmp/src/
WORKDIR /tmp/

RUN mvn clean package -DskipTests

# Runtime container
FROM eclipse-temurin:11-jre

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Expose port 8080
EXPOSE 8080

# Set working directory
WORKDIR /app

# Copy JAR file from builder
COPY --from=maven_build /tmp/target/hello-world-0.1.0.jar app.jar

# Default command
CMD ["java", "-jar", "app.jar"]
