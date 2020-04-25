import os
import re
from multiprocessing.pool import ThreadPool
from typing import List, Pattern

import download_file

urls = []
if not os.path.isdir('downloaded_rules'):
    os.mkdir('downloaded_rules')
download_file.download_file('https://raw.githubusercontent.com/v2ray/domain-list-community/master/data/geolocation-cn')

file_name = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'downloaded_rules', 'geolocation-cn')
with open(file_name, 'r', encoding='utf-8') as f:
    tmplist: List = f.readlines()
    for line in tmplist:
        pattern: Pattern = re.compile(r'^include:')
        _: List = pattern.split(line)
        if _[0] == '':
            urls.append('https://raw.githubusercontent.com/v2ray/domain-list-community/master/data/' + _[1].rstrip())

results = ThreadPool(8).imap_unordered(download_file.download_file, urls)
for path in results:
    pass
