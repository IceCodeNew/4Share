import os
import urllib.request


def get_real_url(url: str):
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0')
    response = urllib.request.urlopen(req)
    real_url = response.geturl()
    return real_url


def save_file(url: str):
    req = urllib.request.Request(url)
    req.add_header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0')
    response = urllib.request.urlopen(req)
    dlfile = response.read()
    os.chdir(os.path.abspath(os.path.dirname(__file__)))
    if not os.path.isdir('downloaded_rules'):
        os.mkdir('downloaded_rules')
    os.chdir('downloaded_rules')
    file_name = url.split('/')[-1]
    with open(file_name, 'wb') as f:
        f.write(dlfile)


def download_file(url: str):
    save_file(get_real_url(url))
