import glob
import os
import shutil
import subprocess

import yaml


def create_role(role):
    ret = subprocess.check_output(
        'ansible-galaxy init {}'.format(role).split())
    if not ret.strip().endswith('created successfully'):
        raise Exception('could not create role "{}"'.format(role))


def get_metadata(role):
    main = open(os.path.join(role, 'meta/main.yml'))
    return yaml.load(main)


def set_metadata(role, metadata):
    new_main = os.path.join(role, 'meta/main.yml.new')
    orig_main = os.path.join(role, 'meta/main.yml')
    with open(new_main, 'w') as out:
        yaml.dump(metadata, out, default_flow_style=False, explicit_start=True)
    os.rename(new_main, orig_main)


def add_dependency(src_role, target_role):
    """Add metadata saying that 'target_role' depends on 'src_role'"""

    md = get_metadata(target_role)
    deps = md.setdefault('dependencies', [])
    deps.append(os.path.join(target_role, 'roles', src_role))
    set_metadata(target_role, md)


def sub_roles(role):
    try:
        return glob.glob(os.path.join(role, 'roles/*'))
    except OSError:
        return []


def fix_dependency(role, for_destination):
    metadata = get_metadata(role)
    deps = metadata.setdefault('dependencies', [])
    metadata['dependencies'] = [os.path.join(for_destination, 'roles', dep)
                                for dep in deps]
    set_metadata(role, metadata)


def fix_dependencies(src_role, for_destination):
    for role in sub_roles(src_role):
        fix_dependencies(role, for_destination)
    fix_dependency(src_role, for_destination)


def move(src_role, target_role, copy=False):
    op = shutil.copytree if copy else shutil.move
    try:
        os.makedirs(os.path.join(target_role, 'roles'))
    except OSError:
        pass
    fix_dependencies(src_role, for_destination=target_role)
    op(src_role, os.path.join(target_role, 'roles', src_role))
    add_dependency(src_role, target_role)


def concat(role1, role2, into, copy=False):
    create_role(into)
    move(role1, target_role=into, copy=copy)
    move(role2, target_role=into, copy=copy)
