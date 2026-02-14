FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy only package files first (better layer caching)
COPY package*.json ./

# Install npm
RUN npm install

# Copy application source
COPY . .

# Expose application port
EXPOSE 5001

# Start application
CMD ["node", "server.js"]
