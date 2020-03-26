import ipaddress
from typing import Tuple, Dict


def ipblock2netaddr_int(input_addr: str) -> Tuple[str, ipaddress.IPv4Network]:
    obj_network = ipaddress.IPv4Network(input_addr.strip('\n'))
    return f'{int(obj_network.network_address):010}', obj_network


write_buffer = []
cleaned_source = []
merged_cidr_dict: Dict[str, ipaddress.IPv4Network] = {}
PKU_net = ('115.27.0.0/16', '162.105.0.0/16', '202.112.7.0/24', '202.112.8.0/24', '222.29.0.0/17', '222.29.128.0/19',)
for _ in PKU_net:
    write_buffer.append(ipblock2netaddr_int(_))

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
                if merged_cidr_dict[retrive_key].subnet_of(ip_block):
                    merged_cidr_dict[retrive_key] = ip_block
                # else:
                #     print('Err: not supernet   ' + str(ip_block))
            except KeyError:
                merged_cidr_dict[retrive_key] = ip_block
                # print('Err: not such key   ' + str(ip_block))
        except ValueError:
            continue


def addr_transfer(net_addr: ipaddress.IPv4Network):
    return str(net_addr.network_address) + '-' + str(net_addr.broadcast_address) + '; '


value: ipaddress.IPv4Network
for i, value in enumerate(merged_cidr_dict.values()):
    if i | 0b1111110000000000 == 0b1111110000000000:
        if i != 0:
            write_buffer[-1] = write_buffer[-1].strip('; ')
            file_name = 'ip_list_' + str(i >> 10) + '.txt'
            with open(file_name, encoding='utf-8', mode='w') as f:
                f.writelines(write_buffer)
                write_buffer.clear()
    try:
        write_buffer.append(addr_transfer(value))
        cleaned_source.append(str(value) + '\n')
    except ValueError:
        continue
i = (i >> 10) + 1
write_buffer[-1] = write_buffer[-1].strip('; ')
with open('ip_list_' + str(i) + '.txt', encoding='utf-8', mode='w') as f:
    f.writelines(write_buffer)

with open('china_ip_list.txt', encoding='utf-8', mode='w') as f:
    f.writelines(cleaned_source)
