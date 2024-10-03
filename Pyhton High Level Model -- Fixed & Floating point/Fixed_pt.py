import numpy as np
import math

def SQNR(x, y):
    
    P_Float = np.abs(np.mean(np.power(x, 2)))
    y = x - y
    P_Noise = np.abs(np.mean(np.power(y, 2)))
    avg = 10 * np.log10(P_Float / P_Noise)
    
    return avg

def quantize_trunc_2(number, num_bits):

    # /2 method
    number = number/2
    #num_bits += 1
    
    # Shift the number to the left to remove the fractional part
    floored_real = np.floor(number.real)
    floored_imag = np.floor(number.imag)
    
    integer_part = floored_real + 1j * floored_imag
    
    # Extract the fractional part
    fractional_part = number - integer_part
    
    # Truncate the fractional part to the specified number of bits
    truncated_fractional_part = np.floor(fractional_part * (2 ** num_bits)) / (2 ** num_bits)
    
    # Combine the integer part and truncated fractional part
    truncated_number = integer_part + truncated_fractional_part
    
    return truncated_number

def quantize_trunc(number, num_bits):
    
    n_real = np.floor(number.real * 2**num_bits)
    n_img = np.floor(number.imag * 2**num_bits)
    
    truncated_number = n_real/2**num_bits + 1j * n_img/2**num_bits
    
    return truncated_number

def quantize_round(number, num_bits):

    
    floored_real = np.floor(number.real)
    floored_imag = np.floor(number.imag)
    
    whole = floored_real + 1j * floored_imag
    x = number - whole
    
    rounded_x = np.round(x * (2 ** num_bits)) / (2 ** num_bits)
    rounded_x = np.where(rounded_x >= 1, 1 - (2 ** (-num_bits)), rounded_x)
    rounded_x = np.where(rounded_x < -1, -1, rounded_x)
    
    return rounded_x + whole

def quantize_round_2(number, num_bits):

    number /= 2
    #num_bits += 1
    
    floored_real = np.floor(number.real)
    floored_imag = np.floor(number.imag)
    
    whole = floored_real + 1j * floored_imag
    x = number - whole
    
    rounded_x = np.round(x * (2 ** num_bits)) / (2 ** num_bits)
    rounded_x = np.where(rounded_x >= 1, 1 - (2 ** (-num_bits)), rounded_x)
    rounded_x = np.where(rounded_x < -1, -1, rounded_x)
    return rounded_x + whole

def bitrevorder(x):
    n = len(x)
    n_bits = int(np.log2(n))

    # Perform bit reversal
    for i in range(n):
        j = int('{:0{width}b}'.format(i, width=n_bits)[::-1], 2)
        if j > i:
            x[i], x[j] = x[j], x[i]

    return x

def bit_rev(arr, base):
    
    def pad_array_to_size(arr, size):
        current_size = arr.size
        if current_size >= size:
            return arr  # No need to pad if array size is already equal or greater than desired size
        else:
            num_zeros_to_add = size - current_size
            padding = [(0, num_zeros_to_add)] + [(0, 0)] * (arr.ndim - 1)  # Pad only along the first axis
            padded_array = np.pad(arr, padding, mode='constant')
            return padded_array
    
    def max_bits(n,b):
        if n == 0:
            return np.array([0])

        digits = []
        while n:
            digits.append(int(n % b))
            n //= b
        
        return len(digits)

    def numberToBase_flip(n, b):
        if n == 0:
            return np.array([0])

        digits = []
        while n:
            digits.append(int(n % b))
            n //= b

        digits = pad_array_to_size(np.array(digits), max_bits(arr.size - 1, base))
        
        return np.flip(digits[::-1])

    def baseToDecimal(digits, base):
        decimal_value = 0
        power = 0
        for digit in reversed(digits):
            decimal_value += digit * (base ** power)
            power += 1
        return decimal_value

    def dec_reord(digit, base):
        base_n = numberToBase_flip(digit, base)
        return baseToDecimal(base_n, base)

    j = [dec_reord(element, base) for element in np.arange(arr.size)]
    
    return arr[j] 

def twiddle(k,N):
    
    return np.exp((-1j * 2 * np.pi * k)/ N)

def twiddle_arr(radix, n):
    
    indices = np.arange(radix)
    
    return twiddle(indices * n, radix) 

def FFT(x, radix, p = 0):
    
    if p == 0:
        p = np.ceil(math.log(len(x), radix))  # Next power of radix
    else:
        p = np.ceil(math.log(p, radix))       # Given length
       
    x = np.concatenate((x, np.zeros(radix**int(p) - len(x))))  # Zero-padding
    N = len(x)
    S = int(math.log(len(x), radix))
    divider = N // radix
    
    for stage in range(0, S):
        for index in range(0, N, N // (radix ** (stage))):
            for n in range(divider):
                pos = n + index
                
                indices = pos + np.arange(radix) * divider
                x_arr = x[indices]
                
                for k in range(radix):
                    
                    twid_arr = twiddle_arr(radix, k)
                    twid_bound_arr = twiddle_arr(N, 1)
                    x[pos + divider * k] = np.dot(x_arr, twid_arr) * twid_bound_arr[(radix**stage) * k * n]
        
        print(min_max_intx(x))
        divider //= radix
    
    y = bit_rev(x, radix)
    return y

def iFFT(x, radix, p = 0):
    
    if p == 0:
        p = np.ceil(math.log(len(x), radix))  # Next power of radix
    else:
        p = np.ceil(math.log(p, radix))       # Given length
    
    y = FFT(x, radix, radix**p)/radix**int(p)
    
    return np.concatenate(([y[0]], y[1:][::-1]))

def FFT_quantize(x, radix, p = 0, b2Q = 9, s2Q = [0,1,2,3,4,5], wQ = 9):
    
    # number of stages we can quantize is (len(array)/2 - 1) 
    # --> 8/2 - 1 = 3 stages we can quantize, output is separate (4) and (0) is input 
    
    if p == 0:
        p = np.ceil(math.log(len(x), radix))  # Next power of radix
    else:
        p = np.ceil(math.log(p, radix))       # Given length
       
    x = np.concatenate((x, np.zeros(radix**int(p) - len(x))))  # Zero-padding
    N = len(x)
    S = int(math.log(len(x), radix))
    divider = N // radix
    
    for stage in range(0, S):
        
        if stage in s2Q:
            x = quantize_trunc(x, b2Q) 
        
        else:
            pass
        
        for index in range(0, N, N // (radix ** (stage))):
            for n in range(divider):
                pos = n + index
                
                indices = pos + np.arange(radix) * divider
                x_arr = x[indices]
                
                for k in range(radix):
                    
                    twid_arr = twiddle_arr(radix, k)
                    twid_arr = np.round(twid_arr)
                    twid_bound_arr = twiddle_arr(N, 1)
                    twid_bound_arr=quantize_trunc(twid_bound_arr,b2Q)
                    x[pos + divider * k] = np.dot(x_arr, twid_arr) * twid_bound_arr[(radix**stage) * k * n]
                        
                                        
        divider //= radix
    
    y = bit_rev(x, radix)
    return y

def FFT_quantize_22(x, radix, p = 0, b2Q = 9, s2Q = [0,1,2,3,4,5], wQ = 9):
    
    # number of stages we can quantize is (len(array)/2 - 1) 
    # --> 8/2 - 1 = 3 stages we can quantize, output is separate (4) and (0) is input 
    
    boundary = np.load('boundary_r22.npy')

    if p == 0:
        p = np.ceil(math.log(len(x), radix))  # Next power of radix
    else:
        p = np.ceil(math.log(p, radix))       # Given length
       
    x = np.concatenate((x, np.zeros(radix**int(p) - len(x))))  # Zero-padding
    N = len(x)
    S = int(math.log(len(x), radix))
    divider = N // radix
    
    for stage in range(0, S):
        
        if stage in s2Q:
            x = quantize_trunc(x, b2Q) * quantize_trunc(boundary[:, stage],9)
            x = quantize_trunc(x, b2Q)
        
        else:
            pass
        
        for index in range(0, N, N // (radix ** (stage))):
            for n in range(divider):
                pos = n + index
                
                indices = pos + np.arange(radix) * divider
                x_arr = x[indices]
                
                for k in range(radix):
                    
                    twid_arr = twiddle_arr(radix, k)
                    twid_arr = np.round(twid_arr)
                    x[pos + divider * k] = np.dot(x_arr, twid_arr)
                        
                                        
        divider //= radix
    
    y = bit_rev(x, radix)
    return y

def iFFT_quantize(x, radix, p = 0, b2Q = 0, s2Q = -1, wQ = 0):
    
    if p == 0:
        p = np.ceil(math.log(len(x), radix))  # Next power of radix
    else:
        p = np.ceil(math.log(p, radix))       # Given length
    
    y = FFT_quantize(x, radix, radix**p, b2Q, s2Q, wQ)/radix**int(p)
    
    return np.concatenate(([y[0]], y[1:][::-1]))
    
def FFT_SQNR(x, radix, bit_l):
    
    q_pts = int(math.log(len(x), radix))    
    q_noise = np.zeros((bit_l, q_pts), dtype = float)
    
    for i in range(q_pts):
        
        for j in range(bit_l):
            
            q_noise[j, i] = SQNR(FFT(x, radix, 64), FFT_quantize(x, radix, 64, j, [i])) 
    
    return q_noise

def group_bits_nr(binary_array, group_size):
    
    reshaped_array = binary_array.reshape(-1, group_size)

    powers_of_2 = 2 ** np.arange(group_size)[::-1]

    decimal_array = np.sum(reshaped_array * powers_of_2, axis=1)

    return decimal_array

def degroup_bits_nr(decimal_array, bits_per_number):
    
    binary_array = np.array([list(format(num, f'0{bits_per_number}b')) for num in decimal_array], dtype=int).flatten()
    
    return binary_array

def min_max_intx(x):
    
    numbers = np.array([np.abs(np.min(x.real)), np.abs(np.max(x.real)), np.abs(np.min(x.imag)), np.abs(np.min(x.imag))])
    b2Qi = np.max(numbers)
    return b2Qi
    
def verilog_import(x, w2Q = 7, b2Q = 9, bT = 1+6+9):
   
    N=x.size
    
    x_real = x.real
    x_img = x.imag

    x_real = np.real(quantize_trunc(x_real,b2Q))
    x_img = np.real(quantize_trunc(x_img,b2Q))
 
    x_real_Q = x_real * (2**b2Q)
    x_img_Q = x_img * (2**b2Q)
    
    x_real_bits = to_binary_array(x_real_Q.astype(int), bT)
    x_img_bits = to_binary_array(x_img_Q.astype(int), bT)
    
    chunks_r = x_real_bits.reshape(-1, 64)
    header = np.array(['zz'] * 16)
    header_repeated = np.tile(header, (chunks_r.shape[0], 1))
    x_real_bits_with_header = np.hstack((header_repeated, chunks_r))
    x_real_bits = x_real_bits_with_header.flatten()
    
    chunks_i = x_img_bits.reshape(-1, 64)
    header = np.array(['zz'] * 16)
    header_repeated = np.tile(header, (chunks_i.shape[0], 1))
    x_img_bits_with_header = np.hstack((header_repeated, chunks_i))
    x_img_bits = x_img_bits_with_header.flatten()
        
    file_path_real = r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\fft_in_r.txt'
    file_path_img =  r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\fft_in_i.txt'

    #file_path_real = r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\out_r.txt'
    #file_path_img  = r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\out_i.txt'

    #file_path_real = r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\out_r.txt'
    #file_path_img =  r'C:\Users\Moham\Downloads\Compressed\r22sdf-master\r22sdf-master\sim\fft_64 - Copy\out_i.txt'


    save_binary_array_to_file(x_real_bits, file_path_real)
    save_binary_array_to_file(x_img_bits, file_path_img)

def to_twos_complement(num, num_bits):
    """
    Convert a number to its two's complement binary representation.

    Args:
    num (int): The number to be converted.
    num_bits (int): The number of bits including the sign bit.

    Returns:
    str: The binary representation of the number in two's complement.
    """
    return format(num if num >= 0 else (1 << num_bits) + num, '0' + str(num_bits) + 'b')

def to_binary_array(arr, num_bits):
    """
    Convert an array of numbers to their two's complement binary representation.

    Args:
    arr (numpy.ndarray): The array of numbers to be converted.
    num_bits (int): The number of bits including the sign bit.

    Returns:
    numpy.ndarray: The array of binary representations.
    """
    twos_complement_func = np.vectorize(lambda x: to_twos_complement(x, num_bits))
    return np.array(list(twos_complement_func(arr)))
    
def save_binary_array_to_file(binary_array, file_path):
    # Convert numpy array to a list of strings
    binary_list = binary_array.tolist()

    # Open the file for writing
    with open(file_path, 'w') as f:
        # Write each string to the file with a newline character
        for binary_string in binary_list:
            f.write(binary_string + '\n')

def apply_fft(x):
    
    array_reshaped = x.reshape(5, 64)
    result = np.ravel(np.apply_along_axis(FFT_quantize_22, axis=1, arr = array_reshaped, radix = 2))
    
    return result

#x = np.load('x.npy')

def twos_complement_to_decimal(binary_arr):
    decimal_arr = []
    for binary_str in binary_arr:
        # Check if the number is negative
        is_negative = binary_str[0] == '1'
        
        # Convert binary string to decimal
        decimal_value = int(binary_str, 2)
        
        # If the number is negative, compute its two's complement
        if is_negative:
            # Calculate the two's complement by subtracting 2^n from the decimal value,
            # where n is the number of bits in the binary string
            num_bits = len(binary_str)
            decimal_value -= 2 ** num_bits
        
        decimal_arr.append(decimal_value)
    
    return np.array(decimal_arr)


def test_sqnr(out):
    
    x_r_v = np.loadtxt('out_v_r.txt', dtype=str, skiprows=3)
    x_i_v = np.loadtxt('out_v_i.txt', dtype=str, skiprows=3)
    
    xv = twos_complement_to_decimal(x_r_v)/2**9 + 1j * twos_complement_to_decimal(x_i_v)/2**9    
    
    return SQNR(xv,out)
    
    
    
    
    
    
    
    
    
    
    