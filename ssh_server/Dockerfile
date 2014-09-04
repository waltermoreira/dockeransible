FROM debian

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server && \
    apt-get clean && \
    mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    cat /etc/ssh/ssh_host_rsa_key.pub > /root/.ssh/authorized_keys && \
    rm -rf /tmp/* /var/log/* /var/tmp/* /var/lib/apt/lists/*

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
