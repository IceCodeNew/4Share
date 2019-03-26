import os
import re
from typing import List, Pattern

import download_file

download_file.download_file('https://raw.githubusercontent.com/v2ray/domain-list-community/master/data/geolocation-cn')

with open(r'geolocation-cn', 'r', encoding='UTF-8') as f:
    tmplist: List = f.readlines()
    for line in tmplist:
        pattern: Pattern = re.compile(r'^include:')
        _: str = pattern.split(line)
        if _[0] == '':
            os.chdir(os.path.abspath(os.path.dirname(__file__)))
            download_file.download_file(
                'https://raw.githubusercontent.com/v2ray/domain-list-community/master/data/' + _[1].rstrip())
