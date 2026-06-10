# Use lightweight alpine-based Nginx image to serve static content
FROM nginx:alpine

# Copy the static web pages to the Nginx default public directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to access the application
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
