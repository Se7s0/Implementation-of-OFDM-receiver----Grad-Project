from Modem import *
from theoretical_SER import *
from basic_channels import *
from OFDM import OFDM
from Veterbi_decoder import *
import commpy.channelcoding.convcode as cc


def group_bits(data_stream, group_size):
    reshaped_array = data_stream.reshape(-1, group_size)
    powers_of_2 = 2 ** np.arange(group_size)[::-1]
    decimal_array = np.sum(reshaped_array * powers_of_2, axis=1)
    
    data_stream.resize((decimal_array.size,), refcheck=False)
    data_stream[:] = decimal_array

def degroup_bits(data_stream, bits_per_number):
    binary_array = np.array([list(format(num, f'0{bits_per_number}b')) for num in data_stream], dtype=int).flatten()\
        
    data_stream.resize((binary_array.size,), refcheck=False)
    data_stream[:] = binary_array

def OFDM_parameter(k, coding_rate, Nused, data_no_pad_size):
    Nbpsc = k
    Ncbps = Nused * k
    Ndbps = Ncbps * coding_rate
    Nsym = int(np.ceil(data_no_pad_size/Ndbps))  #number of symbols in a frame
    Ndata = Nsym * Ndbps                         #data size after padding
    Npad = Ndata - data_no_pad_size              #number of pad bits
    
    return Nbpsc, Ncbps, Ndbps, Nsym, Ndata, Npad
    
def windowfn(x):
    return 0.5*(1+np.cos(((np.pi*x)/(x.size - 1))))

def windowing(Ncp, Nfft, Nsym, modulatedSyms, suffWin):
        
    Lsym = Nfft + Ncp
    
    suffindex = np.arange(0, suffWin, 1, dtype = int)
    suffCos = windowfn(suffindex) 
    
    prefindex = np.arange(0, Ncp, 1, dtype = int)
    prefCos = np.flip(windowfn(prefindex)) 
    
    for i in range(Nsym): 
            
        if (i == 0): 
            modulatedSyms[0, :Ncp] *= prefCos
        
        elif(i == (Nsym - 1)):
            modulatedSyms[i, -suffWin:] *= suffCos
            modulatedSyms[i, :Ncp] = modulatedSyms[i, :Ncp] * prefCos + \
                np.pad(modulatedSyms[i - 1, Ncp : Ncp + suffWin] * suffCos, (0,Ncp-suffWin))
            
            
        else:
            modulatedSyms[i, :Ncp] = modulatedSyms[i, :Ncp] * prefCos + \
                np.pad(modulatedSyms[i - 1, Ncp : Ncp + suffWin] * suffCos, (0,Ncp-suffWin))

def interleaverfn(message, k, Ncbps):
    # Generating binary data ones and zeros
    interleaver_input = np.copy(message)  # Interleaver binary input

    # Interleaver PART
    s = np.ceil(k / 2)
    k = np.arange(Ncbps)
    # First permutation of interleaver
    m = (Ncbps / 16) * np.mod(k, 16) + np.floor(k / 16)
    # Second permutation of interleaver
    n = s * np.floor(m / s) + np.mod(m + Ncbps - np.floor(16 * m / Ncbps), s)
    interleaved_data_out = interleaver_input[n.astype(int)]  # OUTPUT of interleaver
    
    return interleaved_data_out

def deinterleaverfn(message, k, Ncbps):
    # Generating binary data ones and zeros
    deinterleaver_input = np.copy(message)  # Interleaver binary input
    
    # Deinterleaver PART
    j = np.arange(Ncbps)
    s = np.ceil(k / 2)
    # First de-permutation of de-interleaver
    d = s * np.floor(j / s) + np.mod(j + np.floor(16 * j / Ncbps), s)
    # Second de-permutation of de-interleaver
    e = 16 * d - (Ncbps - 1) * np.floor(16 * d / Ncbps)
    deinterleaver_data_out = deinterleaver_input[e.astype(int)]
    return deinterleaver_data_out

def interleaver(message, k, Ncbps):
    
    degroup_bits(message, k)

    reshaped_array = np.reshape(message, (-1,Ncbps))
    message.resize((reshaped_array.shape[0], reshaped_array.shape[1]), refcheck=False)
    
    message[:] = np.apply_along_axis(interleaverfn, axis = 1, arr = message, k = k, Ncbps = Ncbps)
    message.resize((message.size,), refcheck = False)
    group_bits(message, k)
        
def deinterleaver(message, k, Ncbps):
    
    degroup_bits(message, k)
    
    reshaped_array = np.reshape(message, (-1,Ncbps))
    message.resize((reshaped_array.shape[0], reshaped_array.shape[1]), refcheck=False)
    
    message[:] = np.apply_along_axis(deinterleaverfn, axis = 1, arr = message, k = k, Ncbps = Ncbps)
    message.resize((message.size,), refcheck = False)
    group_bits(message, k)
     
def encoder(data_stream, k, trellis):
    degroup_bits(data_stream, k)
    encoded_data = cc.conv_encode(data_stream, trellis,'cont')
    
    data_stream.resize((encoded_data.size,), refcheck=False)
    data_stream[:] = encoded_data
    
    group_bits(data_stream, k)

def decoder(data_stream, ns, out, Nstates, k):
    
    degroup_bits(data_stream, k)
    group_bits(data_stream, 2)
    
    decoded_data = vet_decoder(data_stream, ns, out, Nstates)[0]
    
    data_stream.resize((decoded_data.size,), refcheck=False)
    data_stream[:] = decoded_data

    group_bits(data_stream, k)
    
def perf_anal(nFrame, EbN0dBs, arrayOfM, mod_type, Nfft, Ncp, Nused, Nunused, coding_rate, data_no_pad_size, trellis, mode, L = 1):

    SER_sim = []
    SER_theo = []
    
    out = trellis.output_table
    ns = trellis.next_state_table
    Nstates = trellis.number_states
    
    channel_est_frame = np.loadtxt('channel_frame.txt', dtype=int)
    
    pilot_loc = np.array([0, 6, 19, 40, 53], dtype = int)
    Xp = np.array([0, -1, 1, -1, 1], dtype = complex)
    
    coding_rate = 1 #comment to use encoder

    for M in arrayOfM:

        k = int(np.log2(M))
        Nbpsc, Ncbps, Ndbps, Nsym, Ndata, Npad = OFDM_parameter(k, coding_rate, Nused, data_no_pad_size)        
        data_size = data_no_pad_size + Npad  ##data size to be randomized
        detectedSyms = np.zeros((Nsym + 1, Nused), dtype = int)
        modulatedSyms = np.zeros((Nsym + 1, Nfft + Ncp), dtype = complex)
        
        #Hest = np.zeros((Nsym, 64), dtype = complex)

        
        if (not mode): #AWGN
             EsN0dBs = 10 * np.log10(k) + EbN0dBs  # EsN0dB calculation
        else: #Rayleigh frequency selective fading
            EsN0dBs = 10 * np.log10(k*Nfft/(Nfft+Ncp)) + EbN0dBs  # EsN0dB calculation 
        ser_sim = np.zeros(len(EbN0dBs))  # simulated Symbol error rates 

        for j, EsN0dB in enumerate(EsN0dBs):  

            OFDM_sys = OFDM(EsN0dB, mod_type, M, Nfft, Ncp)

            for _ in range(nFrame):
                
##------------------------------------DATA TRANSMITTER-----------------------------------------------------##
                data_stream = np.random.randint(low = 0, high = M, size = int(data_size/k))
                data_stream_ref = np.copy(data_stream)
                
                #encoder(data_stream, k, trellis)              
                #interleaver(data_stream, k, Ncbps) 
                
                data_stream.resize((Nsym,Nused), refcheck=False) ##serial to parallel
                
                #unused_subcarriers = np.random.randint(low = 0, high = M, size =(Nsym, Nunused))    #now we added the extra subcarriers as gaussian dist
                #inputSyms = np.hstack((data_stream, unused_subcarriers))                            #now we have (Nsym, Nfft) matrix with all subcarriers
                                                                                                     #this line should be replaced by pilots 
                data_stream = np.concatenate(([np.zeros((48,), dtype = int)], data_stream))
                                                                                      
##------------------------------------FRAMING--------------------------------------------------------------##

                #modulate each frame + burst  
                for q in range(Nsym + 1): modulatedSyms[q] = OFDM_sys.Tx(data_stream[q], Xp, pilot_loc, q, channel_est_frame)
                
                #windowing(Ncp, Nfft, Nsym, modulatedSyms, suffWin = 4)      #windowing -> pass by refrence, improves reyleigh channels and some low modulation orders in both channels
                
                ##CFO
                modulatedSyms_burst = np.ravel(modulatedSyms)               #parallel to serial
   
##------------------------------------CHANNEL--------------------------------------------------------------##
                ##CFO
                                   
                #Channel
                if (not mode): #AWGN
                    receivedSyms_burst = awgn(modulatedSyms_burst, EsN0dB)  # transmit through awgn channel
                    H = 1
                else: #Rayleigh frequency selective fading

                    h = (1/np.sqrt(2)) * (np.random.randn(L) + 1j * np.random.randn(L)) #channel impulse response
                    H = np.fft.fft(h,Nfft) #channel frequency response
                    hs = np.convolve(h, modulatedSyms_burst) #filter the OFDM sym through freq. sel. channel
                    receivedSyms_burst = awgn(hs, EsN0dB)[:-(L-1)] #add AWGN noise

##------------------------------------DE - FRAMING--------------------------------------------------------------##

                #demodulate each frame + burst
                receivedSyms = np.reshape(receivedSyms_burst,(Nsym + 1, -1)) #serial to parallel
                
                #receivedSyms = np.load('x_cp.npy')
                #to_verilog_test = np.ravel(receivedSyms[:,16:]) #then save this
                
                ##Channel est
                H_est, channel_est_frame_c, p1, p1_f, H_est_f = OFDM_sys.ch_est(receivedSyms[0], channel_est_frame, Xp, pilot_loc)  ##H_est is preamble after channel and other is original preamble
                
                for q in range(1, Nsym + 1): detectedSyms[q]= OFDM_sys.Rx(receivedSyms[q], H_est, H_est_f, channel_est_frame_c, pilot_loc, Xp, L, EsN0dB, p1, p1_f)
                
                
##------------------------------------RECIEVER--------------------------------------------------------------##
                #Reception             
                #detectedSyms_d = detectedSyms [:, :-16] #extract the data from the used subcarriers, this should have already done in channel estimation
                
                data_stream = np.ravel(detectedSyms[1:]) ##parallel to serial 
                
                #deinterleaver(data_stream, k, Ncbps)  #deinterleaved data here data_streamR is bits
                #decoder(data_stream, ns, out, Nstates, k)
                                
                #accumlate error for this snr 
                # to get original results compare all subcarriers
                err = np.sum(data_stream != data_stream_ref) / (Nfft*Nsym)   #comparison done symbol-wise after sc removal per mod scheme
            

                ser_sim[j] = ser_sim[j] + err
        
        SER_sim.append(ser_sim)
        
        if (not mode): #AWGN
            SER_theo.append(ser_awgn(EbN0dBs, mod_type, M))  # theory SER
        else: #Rayleigh frequency selective fading
            SER_theo.append(ser_rayleigh(EbN0dBs, mod_type, M))

    SER_sim = np.array(SER_sim)
    SER_sim = SER_sim / nFrame

    SER_theo = np.array(SER_theo)

    return SER_sim, SER_theo