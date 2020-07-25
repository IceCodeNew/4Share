import fileinput
import re
from typing import List, Pattern, TextIO


def get_included_urls(indata: str, outf: TextIO):
    pattern_include: Pattern = re.compile(r'^include:')
    pattern_full: Pattern = re.compile(r'^full:')
    pattern_ads: Pattern = re.compile(r'[-@]ads$')
    urls = []

    with fileinput.FileInput(indata, openhook=fileinput.hook_encoded('utf-8', 'surrogateescape')) as infile:
        for _line in infile:
            _line: str = _line.rstrip()
            if len(_line) > 0 and pattern_ads.search(_line) is None:
                _: List = pattern_include.split(_line)
                if _[0] == '':
                    urls.append(
                        'https://raw.githubusercontent.com/v2fly/domain-list-community/master/data/' + _[1])
                else:
                    _: List = pattern_full.split(_line)
                    if _[0] == '':
                        line = _[1]
                    else:
                        line = '*.' + _line
                    outf.write(line)
                    outf.write('\n')
    return urls
