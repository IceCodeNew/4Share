import ipaddress


def addr_v6_transfer(input_addr: str):
    ipv6_addr = ipaddress.IPv6Network(input_addr.strip('\n'))
    return (
        str(ipv6_addr.network_address) + '-' + str(ipv6_addr.broadcast_address) + '; '
    )


# write_buffer = [addr_v6_transfer('2001:da8:201::/48')]
write_buffer = []
i = 1

with open('china-ipv6.txt', encoding='utf-8', mode='r') as cidr_list:
    for line in cidr_list:
        if i | 0b1111111000000000 == 0b1111111000000000:
            if i != 0:
                write_buffer[-1] = write_buffer[-1].strip('; ')
                file_name = 'ipv6_list_' + str(i >> 9) + '.txt'
                f = open(file_name, encoding='utf-8', mode='w')
                f.writelines(write_buffer)
                f.close()
                write_buffer.clear()
        try:
            write_buffer.append(addr_v6_transfer(line))
            i = i + 1
        except ValueError:
            continue

i = (i >> 9) + 1
write_buffer[-1] = write_buffer[-1].strip('; ')
with open('ipv6_list_' + str(i) + '.txt', encoding='utf-8', mode='w') as f:
    f.writelines(write_buffer)
