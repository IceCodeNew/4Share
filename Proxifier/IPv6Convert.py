import ipaddress


def addr_v6_transfer(input_addr: str):
    ipv6_addr = ipaddress.IPv6Network(input_addr.strip('\n'))
    return str(ipv6_addr.network_address) + '-' + str(ipv6_addr.broadcast_address) + '; '


write_buffer = [addr_v6_transfer('2001:da8:201::/48')]
i = 1

with open('china-ipv6.txt', 'r') as cidr_list:
    for line in cidr_list.readlines():
        if i | 0b1111111000000000 == 0b1111111000000000:
            if i != 0:
                write_buffer[-1] = write_buffer[-1].strip('; ')
                file_name = 'ipv6_list_' + str(i // 512) + '.txt'
                f = open(file_name, 'w')
                f.writelines(write_buffer)
                f.close()
                write_buffer.clear()
        write_buffer.append(addr_v6_transfer(line))
        i = i + 1

i = i // 512 + 1
write_buffer[-1] = write_buffer[-1].strip('; ')
with open('ipv6_list_' + str(i) + '.txt', 'w') as f:
    f.writelines(write_buffer)
