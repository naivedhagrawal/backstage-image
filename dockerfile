# Use Node.js as base image
FROM node:20 as builder

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Build the frontend and backend
RUN yarn tsc
RUN yarn build
RUN yarn build:backend --config app-config.production.yaml

# Use a lightweight image for the final container
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy built files from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Expose the Backstage port
EXPOSE 7007

# Start the Backstage app
CMD ["node", "dist/packages/backend"]

