#!/usr/bin/env python
# Copyright 2015, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Based on the rpc-openstack update-yaml located at
# https://github.com/rcbops/rpc-openstack/blob/master/scripts/update-yaml.py

import argparse
from collections import defaultdict
import errno
import yaml


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--list', action='store_const', const=True,
                        default=False, dest='listmerge',
                        help='Merge lists instead of override yaml dict vars')
    parser.add_argument('destination',
                        help='The path to the yaml file to write the'
                             ' overridden configuration.')
    parser.add_argument('overrides', nargs='+',
                        help='The paths to the yaml files with overrides.'
                             ' Each successive argument overrides the previous'
                             ' yaml file.')
    return parser.parse_args()


def get_config(path):
    try:
        with open(path) as f:
            data = f.read()
    except IOError as e:
        if e.errno == errno.ENOENT:
            data = None
        else:
            raise e

    if data is None:
        return {}
    else:
        # assume config is a dict
        return yaml.safe_load(data)


def override_dicts(args):
    base = {}
    for override_file in args.overrides:
        overrides = get_config(override_file)
        if overrides is None:
            continue
        base = dict(base.items() + overrides.items())
    return base


def override_lists(args):
    base = []
    for override_file in args.overrides:
        overrides = get_config(override_file)
        if overrides is None:
            continue
        base = merge_lists(base, overrides)
    return base


def merge_lists(list1, list2, index='name'):
    # used to override list1 items with the list2 overlap based on index
    d = defaultdict(dict)
    for l in (list1, list2):
        for elem in l:
            d[elem[index]].update(elem)
    list3 = d.values()
    return list3


if __name__ == '__main__':
    args = parse_args()
    if args.listmerge:
        base = override_lists(args)
    else:
        base = override_dicts(args)

    if base:
        with open(args.destination, 'w') as f:
            f.write(str(yaml.safe_dump(base, default_flow_style=False)))
