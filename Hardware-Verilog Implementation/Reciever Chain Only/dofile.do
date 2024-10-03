vsim -gui -voptargs=+acc work.Tb_m
run -all

mem save -o C:/Users/Moham/Downloads/Digital_comm_2/Digital_comm_2/out_v_i.txt -f mti -noaddress -data binary -addr decimal -startaddress 0 -endaddress 191 -wordsperline 1 /Tb_m/memo_i
mem save -o C:/Users/Moham/Downloads/Digital_comm_2/Digital_comm_2/out_v_r.txt -f mti -noaddress -data binary -addr decimal -startaddress 0 -endaddress 191 -wordsperline 1 /Tb_m/memo_r

mem save -o C:/Users/Moham/Downloads/Digital_comm_2/Digital_comm_2/demod_v.txt -f mti -noaddress -data unsigned -addr decimal -startaddress 0 -endaddress 191 -wordsperline 1 /Tb_m/memo_sym


