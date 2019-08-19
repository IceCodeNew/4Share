import os
import re
from multiprocessing.pool import ThreadPool
from typing import List, Pattern

import download_file

urls = []

download_file.download_file('https://cdn.statically.io/gh/v2ray/domain-list-community/master/data/geolocation-cn')

with open(r'geolocation-cn', 'r', encoding='UTF-8') as f:
    tmplist: List = f.readlines()
    for line in tmplist:
        pattern: Pattern = re.compile(r'^include:')
        _: List = pattern.split(line)
        if _[0] == '':
            os.chdir(os.path.abspath(os.path.dirname(__file__)))
            urls.append('https://cdn.statically.io/gh/v2ray/domain-list-community/master/data/' + _[1].rstrip())

ThreadPool(8).imap_unordered(download_file, urls)
