FROM ubuntu:22.10
COPY ./dtodo.sh /usr/local/bin/dtodo
LABEL maintainer="skwal.net@gmail.com"
RUN useradd -m -s /bin/bash skwal
USER skwal
CMD ["bash"]