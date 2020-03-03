import ipaddress


def addr_transfer(input_addr):
    net_addr = ipaddress.IPv4Network(input_addr.strip('\n'))
    return str(net_addr.network_address) + '-' + str(net_addr.broadcast_address) + '; '


write_buffer = []
cleaned_source = []
PKU_net = ['162.105.0.0/16', '202.112.7.0/24', '202.112.8.0/24', '222.29.0.0/17', '222.29.128.0/19', '115.27.0.0/16']
for _ in PKU_net:
    write_buffer.append(addr_transfer(_))

i = len(PKU_net)

with open('china_ip_list.txt', encoding='utf-8', mode='r') as cidr_list:
    for line in cidr_list:
        if i | 0b1111110000000000 == 0b1111110000000000:
            if i != 0:
                write_buffer[-1] = write_buffer[-1].strip('; ')
                file_name = 'ip_list_' + str(i // 1024) + '.txt'
                f = open(file_name, encoding='utf-8', mode='w')
                f.writelines(write_buffer)
                f.close()
                write_buffer.clear()
        try:
            write_buffer.append(addr_transfer(line))
            cleaned_source.append(line)
            i = i + 1
        except ValueError:
            continue
with open('china_ip_list.txt', encoding='utf-8', mode='w') as cidr_list:
    cidr_list.writelines(cleaned_source)

i = i // 1024 + 1
write_buffer[-1] = write_buffer[-1].strip('; ')
with open('ip_list_' + str(i) + '.txt', encoding='utf-8', mode='w') as f:
    f.writelines(write_buffer)
