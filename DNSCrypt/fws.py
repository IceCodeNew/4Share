import re
from typing import Tuple

v2raylist = []
dnscryptlist = []


def convert(raw: str):
    pattern_0 = re.compile(r'\*\.')
    pattern_1 = re.compile(r'\.\*\\\.')
    _: Tuple = pattern_0.subn(r'.*\.', raw)
    if _[1] > 1:
        v2raylist.append(pattern_1.sub(r'regexp:', _[0], 1))
        dnscryptlist.append(pattern_1.sub(r'\*.', _[0]))
    elif _[1] == 1:
        v2raylist.append(pattern_1.sub(r'domain:', _[0], 1))
        dnscryptlist.append(raw.lstrip('*.'))
    else:
        v2raylist.append('domain:' + raw)
        dnscryptlist.append(raw)


with open('spy.txt', 'r') as raw_rules:
    for line in raw_rules.readlines():
        convert(line)

with open('extra.txt', 'r') as raw_rules:
    for line in raw_rules.readlines():
        convert(line)

with open('v2rayN_block_rules.txt', 'w') as f:
    f.writelines(v2raylist)
with open('DNSCrypt_black_list.txt', 'w') as f:
    f.writelines(dnscryptlist)
