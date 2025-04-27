FROM dart:stable@sha256:52497b20476fd84cb9f0d63a008b306d75f56f44e54431e510b8cf0e4cc4534a AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml ./
COPY pubspec.lock* ./

# Get dependencies
RUN dart pub get

# Copy the rest of the app
COPY . .

# Build the app
RUN dart pub global activate webdev
RUN dart pub run build_runner build --delete-conflicting-outputs --release
RUN dart compile js -O4 -o build/main.dart.js web/main.dart

# Use a lightweight nginx image to serve the app
FROM nginx:alpine@sha256:65645c7bb6a0661892a8b03b89d0743208a18dd2f3f17a54ef4b76fb8e2f2a10

# Set the open container labels
LABEL org.opencontainers.image.authors="Willian Paixao <willian@ufpa.br>"
LABEL org.opencontainers.image.description="Hello World image running dart web app"
LABEL org.opencontainers.image.source="https://github.com/willianpaixao/helloworld-dart"
LABEL org.opencontainers.image.title="helloworld-dart"

# Copy the build output to nginx's public directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80/tcp

# Set up healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
