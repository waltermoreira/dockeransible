==============
Docker+Ansible
==============

``docker+ansible`` is an utility to streamline the creation of Docker_
images using Ansible_.

The **main goal** of this utility is to allow building images from
small reusable units.  We want to use *composition* rather than
inheritance, as in a regular ``Dockerfile``.


Quickstart
==========

The only dependency is ``docker``.

1. Clone this repository and build the base image with:

   .. code-block:: bash

       $ git clone https://github.com/waltermoreira/dockeransible.git
       $ cd dockeransible/app_builder
       $ make

   This step will create an image with name ``app_builder``.

2. In the ``examples`` directory, create Ansible roles or download
   them from `Ansible Galaxy`_.  Two dummy roles that just create
   files are provided.

   Write or modify the file ``Runfile``, which contains the
   declarations of the exported ports, volumes, entrypoint, and
   default command for your app.

   Run:

   .. code-block:: bash

       $ cd dockeransible/example
       $ docker run -v $(pwd):/target app_builder install
       $ ./build_app.sh my_app

   Ansible will provision a container with name ``my_app`` with the
   provided roles.  The command ``build_app.sh`` may be run multiple
   times, taking advantage of Ansible idempotency. The roles can be
   changed, added, or deleted in between runs.

   Once the container is in the desired state, run:

   .. code-block:: bash

       $ ./build_app.sh commit my_app

   This step creates the image with name ``my_app``.

3. Test your app:

   .. code-block:: bash

       $ docker run -it my_app


License
=======

MIT

.. _Docker: docker.com
.. _Ansible: ansible.com
.. _Ansible Galaxy: galaxy.ansible.com
