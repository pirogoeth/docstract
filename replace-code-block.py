#!/usr/bin/env python
# vim: set ai et ts=4 sts=4 sw=4 syntax=python:
# -*- coding: utf-8 -*-
from __future__ import print_function

import io
import os
import re
import sys


_code_block_ptn = re.compile('.. code-block:: (.+)$')


if __name__ == '__main__':

    if len(sys.argv) < 4:
        print('usage: {} [code block name] [snippet file] [replacement file]'.format(sys.argv[0]))
        sys.exit(-1)

    replacement = sys.argv.pop()
    snippet = sys.argv.pop()
    code_block = sys.argv.pop()

    if not os.access(snippet, os.R_OK):
        print('can not read snippet file!')
        sys.exit(-1)

    if not os.access(replacement, os.R_OK):
        print('can not read replacement file!')
        sys.exit(-1)

    with io.open(snippet, 'r') as snipf:
        from_replacement = False

        for line in snipf.readlines():
            if _code_block_ptn.match(line):
                m = _code_block_ptn.match(line)
                if m.group(1) == code_block:
                    from_replacement = True
                print(line.rstrip('\n'))
            else:
                if from_replacement:
                    print("")
                    with io.open(replacement, 'r') as repl:
                        for rl in repl.readlines():
                            print(rl.rstrip('\n'))
                    from_replacement = False
                else:
                    print(line.rstrip('\n'))
