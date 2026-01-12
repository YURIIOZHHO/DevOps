### Multi-Service Application
#### The goal of this project is to help you practice a more advanced docker setup involving multiple services, volumes, networks, custom base images, multi-stage builds, secrets and more. The project will simulate a real-world scenario with multiple interconnected services, each with its own build requirements and optimizations.

### Requirements
Create a multi-service application using Docker that consists of the following components:
- Web Application: A basic react-based frontend application.
- API Service: A Node.js Express backend API.
- Database: A MongoDB instance for storing application data.
- Cache: A Redis cache for improving performance.
- Reverse Proxy: An Nginx reverse proxy to handle incoming requests.

### Implement the following Docker features and best practices:
- Use Docker Compose to define and run the multi-container application.
- Create custom base images for the web application and API service.
- Implement multi-stage builds for the web application to optimize the final image size.
- Set up a Docker network to allow communication between services.
- Use Docker volumes for persistent data storage (database and cache).
- Configure health checks for service.
- Optimize Dockerfiles for each service to reduce image sizes and improve build times.

#### By completing this project, you'll gain hands-on experience with advanced Docker concepts and best practices in a realistic, multi-service environment. This will prepare you for working with complex containerized applications in production scenarios.


docker-compose.yaml:
```yaml
services:
  frontend:
    build: 
      context: ./frontend/
      dockerfile: Dockerfile.frontend
    container_name: frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-net

  backend:
    build: 
      context: ./backend/
      dockerfile: Dockerfile.backend
    container_name: backend
    ports:
      - "5000:5000"
    depends_on:
      - db
      - redis
    networks:
      - app-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/test"]
      interval: 5s
      timeout: 3s
      retries: 5
    
  db:
    image: mongo:latest
    container_name: mongo
    restart: always
    volumes:
      - mongo-data:/data/db
    networks:
      - app-net    

  redis:
    image: redis:latest
    restart: always
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - app-net

volumes:
  mongo-data:
networks:
  app-net:
```
