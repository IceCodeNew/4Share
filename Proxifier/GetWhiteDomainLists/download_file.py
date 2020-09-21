import os
import urllib.request


def get_real_url(url: str):
    req = urllib.request.Request(url)
    req.add_header(
        "User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36",
    )
    response = urllib.request.urlopen(req)
    real_url = response.geturl()
    return real_url


def save_file(url: str):
    req = urllib.request.Request(url)
    req.add_header(
        "User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36",
    )
    response = urllib.request.urlopen(req)
    dlfile = response.read()
    file_name = os.path.join(os.getcwd(), url.split('/')[-1])
    with open(file_name, 'wb') as f:
        f.write(dlfile)


def download_file(url: str):
    save_file(get_real_url(url))
