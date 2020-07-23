import argparse
import os
import re
from multiprocessing.pool import ThreadPool
from typing import List, Pattern

import download_file

pattern: Pattern = re.compile(r'^include:')
init_path = os.path.abspath(os.path.dirname(__file__))


def start_yield(category: str):
    urls = []
    download_file.download_file('https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/' + category)
    file_name = os.path.join(os.getcwd(), category)
    with open(file_name, 'r', encoding='utf-8') as f:
        tmplist: List = f.readlines()
        for line in tmplist:
            _: List = pattern.split(line)
            if _[0] == '':
                urls.append(
                    'https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/' + _[1].rstrip())

    os.makedirs(category + '.d', exist_ok=True)
    os.chdir(category + '.d')
    results = ThreadPool(8).imap_unordered(download_file.download_file, urls)
    for path in results:
        pass


parser = argparse.ArgumentParser(description='Get full list of specific category-data')
parser.add_argument('data_name', metavar='DataName', nargs='+',
                    help='The name of category-data you would like to specific')
args = parser.parse_args()
_args = list(vars(args).values())[0]
for _name in _args:
    dir_name = os.path.join(init_path, 'downloaded_rules')
    os.makedirs(dir_name, exist_ok=True)
    os.chdir(dir_name)
    start_yield(_name)
