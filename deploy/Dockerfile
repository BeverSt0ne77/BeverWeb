# BeverWeb Deployment Image
# Minimal Alpine image with openssh-client for SCP-based deployment.
#
# Build:
#   docker build -t bever-deploy ./deploy
#
# Run:
#   docker run --rm \
#     --env-file .env \
#     -v $(pwd)/index:/app/index:ro \
#     -v $(pwd)/nginx:/app/nginx:ro \
#     -v $(pwd)/deploy/id_rsa:/root/.ssh/id_rsa:ro \
#     bever-deploy

FROM alpine:3.21

RUN apk add --no-cache openssh-client

COPY deploy.sh /app/deploy.sh
RUN chmod +x /app/deploy.sh

WORKDIR /app

ENTRYPOINT ["/app/deploy.sh"]
