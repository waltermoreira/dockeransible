#!/usr/bin/python

import glob
import os
import shutil
import subprocess
import sys

import yaml


def create_role(role):
    ret = subprocess.check_output(
        'ansible-galaxy init {}'.format(role).split())
    if not ret.strip().endswith('created successfully'):
        raise Exception('could not create role "{}"'.format(role))


def get_metadata(role):
    try:
        main = open(os.path.join(role, 'meta/main.yml'))
        return yaml.load(main)
    except IOError:
        return {}


def ensure_meta(role):
    """Ensure the role has a meta directory"""

    try:
        os.makedirs(os.path.join(role, 'meta'))
    except OSError:
        pass


def set_metadata(role, metadata):
    ensure_meta(role)
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
    """Fix the sub-role dependency.

    Dependency on a sub-role has to be changed once we move the base
    role.

    """
    metadata = get_metadata(role)
    deps = metadata.setdefault('dependencies', [])
    def f(dep):
        if dep.startswith(role):
            return os.path.join(for_destination, 'roles', dep)
        else:
            return dep
    metadata['dependencies'] = [f(dep) for dep in deps]
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


def concat(roles, into, copy=False):
    create_role(into)
    for role in roles:
        move(role, target_role=into, copy=copy)


def test():
    roles = ['foo', 'bar', 'spam']
    try:
        for role in roles:
            create_role(role)
        move('foo', 'bar')
        assert get_metadata('bar')['dependencies'] == ['bar/roles/foo']

        move('bar', 'spam')
        assert get_metadata('spam')['dependencies'] == ['spam/roles/bar']
        assert get_metadata('spam/roles/bar')['dependencies'] == ['spam/roles/bar/roles/foo']
    finally:
        for role in roles:
            shutil.rmtree(role, ignore_errors=True)


def main():
    roles_path = None
    if roles_path is not None:
        os.chdir(roles_path)
    concat([sys.argv[1], sys.argv[2]], into=sys.argv[3])


if __name__ == '__main__':
    main()
