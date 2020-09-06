import collections
import ipaddress
import pathlib
from typing import Tuple, OrderedDict, List


def ipblock2netaddr_int(input_addr: str) -> Tuple[int, ipaddress.IPv4Network]:
    obj_network = ipaddress.IPv4Network(input_addr.strip('\n'))
    return int(obj_network.network_address), obj_network


def addr_transfer(net_addr: ipaddress.IPv4Network):
    return str(net_addr.network_address) + '-' + str(net_addr.broadcast_address) + '; '


_: Tuple
write_buffer = []
merged_cidr_dict: OrderedDict[int, ipaddress.IPv4Network] = collections.OrderedDict()
PKU_net = ('115.27.0.0/16', '162.105.0.0/16', '202.112.7.0/24', '202.112.8.0/24', '222.29.0.0/17', '222.29.128.0/19',)
for _tmp_str in PKU_net:
    write_buffer.append(ipblock2netaddr_int(_tmp_str))

with open('china_ip_list.txt', encoding='utf-8', mode='r') as cidr_list:
    for line in cidr_list:
        try:
            write_buffer.append(ipblock2netaddr_int(line))
        except ValueError:
            continue
merged_cidr_dict.update(write_buffer)

with open('china-ipv4.txt', encoding='utf-8', mode='r') as cidr_list:
    for line in cidr_list:
        try:
            _ = ipblock2netaddr_int(line)
            retrive_key = _[0]
            ip_block = _[1]
            try:
                if not ip_block.subnet_of(merged_cidr_dict[retrive_key]):
                    merged_cidr_dict[retrive_key] = ip_block
            except KeyError:
                merged_cidr_dict[retrive_key] = ip_block
        except ValueError:
            continue

_tmp_list: List[ipaddress.IPv4Network] = []
for _ in sorted(merged_cidr_dict.items()):
    _tmp_list.append(_[1])
_tmp_iterator = ipaddress.collapse_addresses(_tmp_list)
compressed_cidr_list: List[ipaddress.IPv4Network] = list(_tmp_iterator)

write_buffer.clear()
i = 0
value: ipaddress.IPv4Network
for i, value in enumerate(compressed_cidr_list):
    if i | 0b1111110000000000 == 0b1111110000000000:
        if i != 0:
            write_buffer[-1] = write_buffer[-1].strip('; ')
            file_name = 'ip_list_' + str(i >> 10) + '.txt'
            with open(file_name, encoding='utf-8', mode='w') as f:
                f.writelines(write_buffer)
                write_buffer.clear()
    try:
        write_buffer.append(addr_transfer(value))
    except ValueError:
        continue
i = (i >> 10) + 1
write_buffer[-1] = write_buffer[-1].strip('; ')
with open('ip_list_' + str(i) + '.txt', encoding='utf-8', mode='w') as f:
    f.writelines(write_buffer)

with open('china_ip_list.txt', encoding='utf-8', mode='w') as f:
    path_clash = pathlib.Path(__file__).resolve().parents[1].joinpath('Clash', 'ICN')
    with open(str(path_clash) + 'CHINA_IP_LIST.yaml', encoding='utf-8', mode='w') as fyaml:
        for address in compressed_cidr_list:
            f.write(f'{str(address)}\n')
            fyaml.write(f"  - 'IP-CIDR,{str(address)},DIRECT'\n")
