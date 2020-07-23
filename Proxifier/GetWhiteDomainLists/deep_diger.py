import argparse
import fileinput
import os
import re
from multiprocessing.pool import ThreadPool
from shutil import rmtree
from typing import List, Pattern

from download_file import download_file

parser = argparse.ArgumentParser(description='Get full list of included domains in user-specified category-data')
parser.add_argument('data_name', metavar='DataName', nargs=1, help='The name of category-data you previously specified')
args = parser.parse_args()
category_name = list(vars(args).values())[0][0]

pattern: Pattern = re.compile(r'^include:')
root_path = os.path.abspath(os.path.dirname(__file__))
os.chdir(os.path.join(root_path, 'downloaded_rules'))
with open(category_name, 'a', encoding='utf-8') as f:
    urls = []
    with fileinput.input(files='-') as infile:
        for line in infile:
            _: List = pattern.split(line)
            if _[0] == '':
                urls.append(
                    'https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/' + _[1].rstrip())
            else:
                f.write(line)

category_path = os.path.join(root_path, 'downloaded_rules', category_name + '.d')
rmtree(category_path)
if len(urls) > 0:
    os.makedirs(category_path, exist_ok=False)
    os.chdir(category_path)
    results = ThreadPool(8).imap_unordered(download_file, urls)
    for path in results:
        pass
