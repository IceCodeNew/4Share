import argparse
import os
from multiprocessing.pool import ThreadPool
from shutil import move
from typing import List

from download_file import download_file
from get_included_urls import get_included_urls


def start_yield(category: str):
    download_file('https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/' + category)
    move(category, category + '.ori')
    with open(category, 'w', encoding='utf-8') as f:
        urls: List = get_included_urls(category + '.ori', f)
    os.remove(category + '.ori')
    os.makedirs(category + '.d', exist_ok=False)
    os.chdir(category + '.d')
    results = ThreadPool(8).imap_unordered(download_file, urls)
    for path in results:
        pass


parser = argparse.ArgumentParser(description='Get full list of specific category-data')
parser.add_argument('data_name', metavar='DataName', nargs='+',
                    help='The name of category-data you would like to specific')
args = parser.parse_args()
_args = list(vars(args).values())[0]
root_path = os.path.abspath(os.path.dirname(__file__))
for _name in _args:
    dir_name = os.path.join(root_path, 'downloaded_rules')
    os.makedirs(dir_name, exist_ok=True)
    os.chdir(dir_name)
    start_yield(_name)
