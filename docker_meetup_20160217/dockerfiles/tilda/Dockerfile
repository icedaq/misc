FROM debian:jessie
MAINTAINER Pascal Liniger <pascal.liniger@infix.ch>

# Install Tilda
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	tilda ssh

ENTRYPOINT [ "tilda" ]
