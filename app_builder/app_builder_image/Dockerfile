FROM debian

ADD build_app.sh /bin/build_app.sh
ADD entry.sh /bin/entry.sh
ADD setup_ansible.sh /bin/setup_ansible.sh
ADD concat_roles.py /bin/concat_roles.py

RUN /bin/setup_ansible.sh

ENTRYPOINT ["/bin/entry.sh"]
CMD []
