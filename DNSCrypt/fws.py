import re
from typing import Tuple

v2raylist = []


def convert(raw: str):
    pattern_0 = re.compile(r'\*\.')
    pattern_1 = re.compile(r'\.\*\\\.')
    _: Tuple = pattern_0.subn(r'.*\.', raw)
    if _[1] > 1:
        v2raylist.append(pattern_1.sub(r'regexp:', _[0], 1).rstrip() + '\n')
    elif _[1] == 1:
        v2raylist.append(pattern_1.sub(r'domain:', _[0], 1).rstrip() + '\n')
    else:
        v2raylist.append('domain:' + raw.rstrip() + '\n')


with open('mybase.txt', 'r') as raw_rules:
    pattern_comment = re.compile(r'^#|^$')
    for line in raw_rules.readlines():
        if pattern_comment.match(line) is None:
            convert(line)

v2raylist.sort()
with open('v2rayN_block_rules.txt', 'w') as f:
    f.writelines(v2raylist)
