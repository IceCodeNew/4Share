#!/usr/bin/env python
# coding:utf-8
"""
# 使用XML解析.ppx
# Author: Karonheaven
"""
# +---------------+需要的包+---------------+
from typing import List, Dict, Tuple, Set
import os
import re
import xml.etree.ElementTree as ET


# +---------------+预定义函数+---------------+
def fix_illegal_chars(raw_str: str) -> str:
    """
    将Windows文件管理器不支持的非法字符替换为下划线
    
    :param raw_str: 原字符串
    :return: 替换后的字符串
    """
    rstr = r"[\/\\\:\*\?\"\<\>\|]"
    return re.sub(rstr, "_", raw_str)


def split_multi_targets(target_str: str) -> List[str]:
    """
    将以分号分隔开的多个目标拆分为列表
    
    :param target_str: 多个目标
    :return: 列表形式的独立目标
    """
    list_raw = target_str.split(";")
    list_target: List[str] = []
    for target in list_raw:
        target = target.strip()
        if target != "":
            list_target.append(target)
    
    return list_target


def convert_domain(raw_domain: str) -> str:
    """
    将proxifier形式的domain转换为clash形式的domain
    
    :param raw_domain: domain(proxifier)
    :return: domain(clash)
    """
    raw_domain = raw_domain.strip()
    if raw_domain.find("www") != -1:
        return raw_domain.replace("www", "+")
    elif raw_domain.find("*") != -1:
        return raw_domain.replace("*", "+")
    else:
        print(raw_domain)
        return raw_domain


# +---------------+主程序+---------------+
root: ET.Element  # root
label_2nd: ET.Element  # <RuleList>
label_3rd: ET.Element  # <Rule>
label_4th: ET.Element  # <Name>/<Applications>/<Action

tg_enabled: bool  # false: 禁用，true: 启用
tg_name: str  # 名字
tg_type: str  # 类型，process or domain
tg_list: List[str]
tg_action: str  # Block or Direct or Proxy

# 使用ElementTree解析XML
tree = ET.parse("./4Share - 10808.ppx")
root: ET.Element = tree.getroot()
if root.tag != "ProxifierProfile":
    raise ValueError("不是标准的.ppx文件")

# 准备工作
if not os.path.exists("./rule-sets"):
    print("创建文件夹..")
    os.makedirs("./rule-sets")

for label_3rd in root.find("RuleList"):
    # 获取基本数据
    tg_enabled = bool(label_3rd.attrib["enabled"])
    tg_name = label_3rd.find("Name").text
    if tg_name == "Default":
        continue
    
    if label_3rd.find("Applications") is not None:
        tg_type = "process"
        tg_list = split_multi_targets(target_str=label_3rd.find("Applications").text)
    elif label_3rd.find("Targets") is not None:
        tg_type = "domain"
        tg_list = split_multi_targets(target_str=label_3rd.find("Targets").text)
    else:
        raise ValueError("type错误，rule name: {}".format(tg_name))
    tg_action = label_3rd.find("Action").attrib["type"]
    if tg_action == "Block":
        tg_action = "REJECT"
    elif tg_action == "Direct":
        tg_action = "DIRECT"
    elif tg_action == "Proxy":
        tg_action = "Proxy"
    else:
        raise ValueError("action错误，rule name: {}".format(tg_name))
    
    # print(tg_enabled, tg_name, tg_type, tg_list, tg_action)
    file_write = open(file="./rule-sets/{}-{}.yaml".format(tg_type, fix_illegal_chars(raw_str=tg_name)), mode="w+",
                      encoding="utf-8")
    # 如果是domain类型，则按照以下形式写入文件
    # payload:
    #   - "+.baidu.com"
    #   - "+.baiduapi.com"
    if tg_type == "domain":
        file_write.write("payload:\n")
        for target in tg_list:
            file_write.write("  - \"{}\"\n".format(convert_domain(raw_domain=target)))
    else:
        file_write.write("payload:\n")
        for target in tg_list:
            file_write.write("  - PROCESS-NAME,{},{}\n".format(target.strip(), tg_action))
    
    pass
