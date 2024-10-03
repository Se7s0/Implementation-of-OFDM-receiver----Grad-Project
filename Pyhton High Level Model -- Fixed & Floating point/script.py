import numpy as np
import matplotlib, matplotlib.pyplot as plt

from OFDM_testing_script import *

import numpy as np

from Modem import *
from Fixed_pt import *

import math

# Input parameters
nFrame = int(30 * 1e1) # Number of symbols to transmit
EbN0dBs = np.arange(start=0,stop = 12, step = 2) # Eb/N0 range in dB for simulation

# OFDM Parameters
Nfft = 64 #FFT size or total number of subcarriers (used + unused)
Nused = 48
Nunused = Nfft - Nused
Ncp= 16 #number of symbols in the cyclic prefix


# Data to be sent --> we are only intrested with its size for now
Nchar = 40
NcharBits = Nchar * 8 #ASCII
data_no_pad_size = NcharBits + 16 + 6 #data + service + tail   
                                                    #     +padding(depends on mod order)
coding_rate = 1

import commpy.channelcoding.convcode as cc

memory = np.array([6])
g_matrix =np. array([[0o155, 0o117]])
trellis = cc.Trellis(memory, g_matrix)

def plot_res(EbN0dBs, SER_sim, SER_theo, mod_type, arrayOfM, plot_type): 

    colors = plt.cm.jet(np.linspace(0,1,len(arrayOfM))) # colormap
    fig, ax = plt.subplots(nrows=1,ncols = 1)

    for i, M in enumerate(arrayOfM):
        ax.semilogy(EbN0dBs,SER_sim[i,:],color = colors[i],marker='o',linestyle='',label='Sim '+str(M)+'-'+mod_type.upper())
        ax.semilogy(EbN0dBs,SER_theo[i,:],color = colors[i],linestyle='-',label='Theory'+str(M)+'-'+mod_type.upper())


    ax.set_xlabel('Eb/N0(dB)');ax.set_ylabel('SER ($P_s$)')
    ax.set_title('Probability of Symbol Error for M-'+str(mod_type)+ '-CP-OFDM' +' over ' + plot_type)
    ax.legend()
    #fig.show()


mod_type = 'QAM' # Set 'PSK' or 'QAM' or 'PAM' tes
arrayOfM=[4, 16, 64, 256] # square QAM

SER_sim = []
SER_theo = []

out = trellis.output_table
ns = trellis.next_state_table
Nstates = trellis.number_states

channel_est_frame = np.loadtxt('channel_frame.txt', dtype=int)

pilot_loc = np.array([0, 6, 19, 40, 53], dtype = int)
Xp = np.array([0, -1, 1, -1, 1], dtype = complex)

coding_rate = 1 #comment to use encoder

M = 4
mode = 1
k = int(np.log2(M))
Nbpsc, Ncbps, Ndbps, Nsym, Ndata, Npad = OFDM_parameter(k, coding_rate, Nused, data_no_pad_size)        
data_size = data_no_pad_size + Npad  ##data size to be randomized
detectedSyms = np.zeros((Nsym + 1, Nused), dtype = int)
detectedSyms_f = np.zeros((Nsym + 1, Nused), dtype = int)

detectedSyms_c = np.zeros((Nsym + 1, Nused), dtype = complex)
detectedSyms_f_c = np.zeros((Nsym + 1, Nused), dtype = complex)

#detectedSyms_2 = np.zeros((Nsym + 1, Nused), dtype = complex)
modulatedSyms = np.zeros((Nsym + 1, Nfft + Ncp), dtype = complex)

EbN0dBs = 10
if (not mode): #AWGN
    EsN0dBs = 10 * np.log10(k) + EbN0dBs  # EsN0dB calculation
else: #Rayleigh frequency selective fading
    EsN0dBs = 10 * np.log10(k*Nfft/(Nfft+Ncp)) + EbN0dBs  # EsN0dB calculation 

EsN0dB = EsN0dBs

OFDM_sys = OFDM(EsN0dB, mod_type, M, Nfft, Ncp)

data_stream =  np.load('data_stream_ref.npy') #np.random.randint(low = 0, high = M, size = int(data_size/k))
data_stream_ref = np.copy(data_stream)

#encoder(data_stream, k, trellis)              
#interleaver(data_stream, k, Ncbps) 

data_stream.resize((Nsym,Nused), refcheck=False) ##serial to parallel

data_stream = np.concatenate(([np.zeros((48,), dtype = int)], data_stream))

for q in range(Nsym + 1): modulatedSyms[q] = OFDM_sys.Tx(data_stream[q], Xp, pilot_loc, q, channel_est_frame)

modulatedSyms_burst = np.ravel(modulatedSyms)               #parallel to serial

b5eet_imp = modulatedSyms_burst[80:]

L = 2

if (not mode): #AWGN
    receivedSyms_burst = awgn(modulatedSyms_burst, EsN0dB)  # transmit through awgn channel
    H = 1
else: #Rayleigh frequency selective fading
    h = (1/np.sqrt(2)) * (np.random.randn(L) + 1j * np.random.randn(L)) #channel impulse response
    H = np.fft.fft(h,Nfft) #channel frequency response
    hs = np.convolve(h, modulatedSyms_burst) #filter the OFDM sym through freq. sel. channel
    receivedSyms_burst = awgn(hs, EsN0dB)[:-(L-1)] #add AWGN noise

# #insert b5eet long+symbols rec_burst
# receivedSyms_burst = np.loadtxt('complex.txt', dtype=complex)/(2**15-1)
 

# reshaped_array = receivedSyms_burst.reshape(-1, 64)

# # Create an array of zeros with 16 columns
# zeros = np.zeros((reshaped_array.shape[0], 16))

# # Stack the zeros array before each block of 64 elements
# result = np.hstack((zeros, reshaped_array))

# # Reshape the result back to a 1D array
# receivedSyms_burst = result.reshape(-1)

receivedSyms = np.reshape(receivedSyms_burst,(Nsym + 1, -1)) #serial to parallel


verilog_import(np.ravel(receivedSyms[:, 16:]))

H_est, channel_est_frame_c, p1, p1_f, H_est_f = OFDM_sys.ch_est(receivedSyms[0], channel_est_frame, Xp, pilot_loc)
for q in range(1, Nsym + 1): detectedSyms[q], detectedSyms_f[q], detectedSyms_c[q], detectedSyms_f_c[q] = OFDM_sys.Rx(receivedSyms[q], H_est, H_est_f, channel_est_frame_c, pilot_loc, Xp, L, EsN0dB, p1, p1_f)

out = np.ravel(detectedSyms[1:])
out_f = np.ravel(detectedSyms_f[1:])

out_c = np.ravel(detectedSyms_c[1:])
out_f_c = np.ravel(detectedSyms_f_c[1:])



# receivedSyms_burst = np.loadtxt('complex.txt', dtype=complex)/2**15

# receivedSyms = np.reshape(receivedSyms_burst,(Nsym + 1, -1)) #serial to parallel

# H_est, channel_est_frame_c, p1 = OFDM_sys.ch_est(receivedSyms[0], channel_est_frame, Xp, pilot_loc)
# for q in range(1, Nsym + 1): detectedSyms_2[q]= OFDM_sys.Rx(receivedSyms[q], H_est, channel_est_frame_c, pilot_loc, Xp, L, EsN0dB, p1)

# out2 = np.ravel(detectedSyms_2[1:])

# out = np.ravel(detectedSyms[1:])

demod_v =np.loadtxt('demod_v.txt', dtype=int, skiprows=3)

err = np.sum(data_stream_ref != out_f)

#print(test_sqnr(out))



