import collections
import ipaddress
from typing import Tuple, OrderedDict, Deque


def ipblock2netaddr_int(input_addr: str) -> Tuple[int, ipaddress.IPv4Network]:
    obj_network = ipaddress.IPv4Network(input_addr.strip('\n'))
    return int(obj_network.network_address), obj_network


def delete_nth(d: Deque, n: int):
    d.rotate(-n)
    d.popleft()
    d.rotate(n)


def addr_transfer(net_addr: ipaddress.IPv4Network):
    return str(net_addr.network_address) + '-' + str(net_addr.broadcast_address) + '; '


write_buffer = []
merged_cidr_dict: OrderedDict[int, ipaddress.IPv4Network] = collections.OrderedDict()
PKU_net = ('115.27.0.0/16', '162.105.0.0/16', '202.112.7.0/24', '202.112.8.0/24', '222.29.0.0/17', '222.29.128.0/19',)
for _str in PKU_net:
    write_buffer.append(ipblock2netaddr_int(_str))

with open('china_ip_list.txt', encoding='utf-8', mode='r') as cidr_list:
    for line in cidr_list:
        try:
            write_buffer.append(ipblock2netaddr_int(line))
        except ValueError:
            continue
merged_cidr_dict.update(write_buffer)
write_buffer.clear()

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

compressed_cidr_deque: Deque[ipaddress.IPv4Network] = collections.deque()
_list = sorted(merged_cidr_dict.items())
_: Tuple
for _ in _list:
    compressed_cidr_deque.append(_[1])

while True:
    prev_len = len(compressed_cidr_deque)
    for i in range(len(compressed_cidr_deque) - 1):
        try:
            while True:
                _tuple = tuple(ipaddress.collapse_addresses([compressed_cidr_deque[i], compressed_cidr_deque[i + 1]]))
                if len(_tuple) == 1:
                    compressed_cidr_deque[i] = _tuple[0]
                    delete_nth(compressed_cidr_deque, i + 1)
                else:
                    break
        except IndexError:
            break
    if len(compressed_cidr_deque) == prev_len:
        break

i = 0
value: ipaddress.IPv4Network
for i, value in enumerate(compressed_cidr_deque):
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
    for address in compressed_cidr_deque:
        f.write(f'{str(address)}\n')
