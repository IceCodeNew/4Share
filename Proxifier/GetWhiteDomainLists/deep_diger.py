import argparse
import os
from multiprocessing.pool import ThreadPool
from shutil import rmtree
from typing import List

from download_file import download_file
from get_included_urls import get_included_urls

parser = argparse.ArgumentParser(
    description='Get full list of included domains in user-specified category-data'
)
parser.add_argument(
    'data_name',
    metavar='DataName',
    nargs=1,
    help='The name of category-data you previously specified',
)
args = parser.parse_args()
category_name = list(vars(args).values())[0][0]

root_path = os.path.abspath(os.path.dirname(__file__))
os.chdir(os.path.join(root_path, 'downloaded_rules'))
with open(category_name, 'a', encoding='utf-8') as f:
    urls: List = get_included_urls('-', f)

category_path = os.path.join(root_path, 'downloaded_rules', category_name + '.d')
rmtree(category_path)
if len(urls) > 0:
    os.makedirs(category_path, exist_ok=False)
    os.chdir(category_path)
    results = ThreadPool(8).imap_unordered(download_file, urls)
    for path in results:
        pass
