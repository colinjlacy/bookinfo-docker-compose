FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the traffic generation script
COPY generate-traffic.js ./

# Run as non-root user
USER node

# Set the entrypoint to run the Node.js script
ENTRYPOINT ["node", "generate-traffic.js"]

