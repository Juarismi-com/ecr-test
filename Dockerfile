# Use official Node.js runtime as base image
FROM node:20-alpine

# Set working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Expose port 3000 (adjust if needed)
EXPOSE 3000

# Define the command to run the application
CMD ["node", "app.js"]

