FROM alpine/git

COPY --from=digitalocean/doctl /app/doctl /bin/doctl
COPY --from=minio/mc /bin/mc /bin/mc

# Run as non-root
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

RUN mkdir -p /home/app \
    && chown -R app /home/app

USER 1000
WORKDIR /home/app

COPY main.sh /home/app/main.sh

ENTRYPOINT ["/home/app/main.sh"]
