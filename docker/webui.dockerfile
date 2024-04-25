FROM ubuntu:jammy

MAINTAINER Motohiro Abe <motohiro@gmail.com>

# based on v2.7.0

# Install necessary packages
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Create a deb repository for Node.js
ARG NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

# Update package information and install Node.js
RUN apt-get update && \
    apt-get install -y nodejs git && \
    git clone -b v2.7.0 https://github.com/open5gs/open5gs.git

WORKDIR /open5gs/webui

RUN npm install && npm run build

CMD npm run start

EXPOSE 3000
