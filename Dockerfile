# ================================
# Build image
# ================================
FROM swiftarm/swift:latest as build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations
RUN swift build -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/stumpy" ./

# ================================
# Run image
# ================================
FROM swiftarm/swift:latest

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y && rm -r /var/lib/apt/lists/*

# Create a stumpy user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app stumpy

# Switch to the new home directory
WORKDIR /app

# Copy built executable
COPY --from=build --chown=stumpy:stumpy /staging /app

# Ensure all further commands run as the stumpy user
USER stumpy:stumpy

EXPOSE 1081
EXPOSE 9191

# Start the stumpy service when the image is run, default to listening on 1081 and 9191 in production environment
ENTRYPOINT ["./stumpy"]
CMD ["--smtp-port", "1081", "--pop-port", "9191", "--store-size", "10", "--threads", "2"]
