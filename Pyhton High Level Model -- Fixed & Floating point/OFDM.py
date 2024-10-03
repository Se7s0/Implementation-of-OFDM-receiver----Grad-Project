import numpy as np

from Modem import *
from Fixed_pt import *

class OFDM:

    def __init__(self, EsN0dB, mod_type, M, Nfft, Ncp) -> None:
        
        self.EsN0dB = EsN0dB #bit to noise ratio

        self.M = M #modulation order
        self.modem_dict = {'psk': PSKModem,'qam':QAMModem,'pam':PAMModem}
        self.mod_type = mod_type
        self.modem = self.modem_dict[self.mod_type.lower()](M) 

        self.Nfft = Nfft #FFT size or total number of subcarriers (used + unused) 
        self.Ncp = Ncp #number of symbols in the cyclic prefix
        
    def pilot_add(self, data, Xp, pilot_loc):
        
        symbol = np.insert(data, 23 + 1, np.zeros(11))
        symbol = np.insert(symbol, pilot_loc, Xp)
        
        return symbol
    
    def data_extract(self, Y, Xp, pilot_loc):
        
        symbol = np.zeros((48,), dtype = complex)
        
        
        pilot_avoid = np.array([0, 7, 21, 43, 57])
        pilot_after = Y[pilot_avoid[1:]]
        #phase_offset = np.conj(np.average(pilot_after * Xp))
        
        avoid_indices = np.concatenate([np.arange(27, 38), pilot_avoid])        
        source_index = 0
        
        for i in range(self.Nfft):
            if i not in avoid_indices:
                symbol[source_index] = Y[i]
                source_index += 1
        
        return symbol, pilot_after
        
    def LS_CE(self, Y, Xp, pilot_loc, Nfft):
        
        LS_est = np.zeros((4,), dtype = complex)
        
        for k in range(4):
            LS_est[k] = Y[pilot_loc[k]] / Xp[k]
            
        slope_s = (LS_est[1] - LS_est[0])/(pilot_loc[1] - pilot_loc[0])
        slope_e = (LS_est[-1] - LS_est[-2])/(pilot_loc[-1] - pilot_loc[-2]) 

        H_start = LS_est[1] - slope_s * (pilot_loc[0] - 1)
        H_end = LS_est[-1] + slope_s * (Nfft - pilot_loc[-1])
        
        LS_MSE = np.copy(LS_est)

        LS_est = np.concatenate(([H_start], LS_est, [H_end]))
        pilot_loc = np.concatenate(([0], pilot_loc, [63]))
        
        x = np.linspace(0, Nfft-1, Nfft, dtype =int)
        H_est = np.interp(x, pilot_loc, LS_est)
        
        return H_est, LS_MSE
    
    def DFT_CE(self, H, L):
        
        x = iFFT(H, 8, self.Nfft)
                
        x = x[:L]
                
        #H_dft = FFT_quantize(x, 4, self.Nfft, 8, np.arange(0,3))       
        H_dft = np.fft.fft(x, self.Nfft)
        return H_dft, x
    
    def MSE_CE(self, pilot_loc, h_est_ls, SNR, H_tilde):
        
        snr = 10**(SNR*0.1)
        Nps = 14
        k = np.arange(0, h_est_ls.size)
        #H_tilde = H_LS[pilot_loc]
                
        hh = np.dot(h_est_ls, np.conjugate(h_est_ls).T)
        
        tmp = h_est_ls * np.conj(h_est_ls) * k
        
        r = np.sum(tmp)/hh
        
        r2 = np.dot(tmp, k.T)/hh
        
        tau_rms = np.sqrt(r2 - r**2)
        
        df = 1/self.Nfft
        
        j2pi_tau_df = 1j * tau_rms * df * np.pi * 2
        
        K1_mat = np.arange(0, self.Nfft)
        
        K1 = np.tile(K1_mat, (4,1)).T
        
        K2_mat = np.arange(0,4)
        
        K2 = np.tile(K2_mat, (self.Nfft,1))
        
        rf = 1/(1+j2pi_tau_df*(K1-(K2 * Nps + 11)))
        
        K3_K4_mat = np.arange(0,4)
        
        K4 = np.tile(K3_K4_mat, (4,1))

        K3 = K4.T 
        
        rf2 = 1/(1+j2pi_tau_df*Nps*(K3-K4))
        
        Rhp = rf;
        
        Rpp = rf2 + np.identity(H_tilde.size)/snr
        Rpp_inv = np.linalg.inv(Rpp)
        
        
        H_est = np.dot(np.dot(Rhp, Rpp_inv), H_tilde)
        
        return H_est
        
    def interp_lin(self):
        
        ##
        
        return
        
    def Tx(self, ip_sym, Xp, pilot_loc, q, channel_est_frame):
        if q==0:
            
            symbol = channel_est_frame
        
        else: 
            #modulate input symbols - Mapping
            modulatedSyms = self.modem.modulate(ip_sym) 
        
            symbol = self.pilot_add(modulatedSyms, Xp, pilot_loc)

        # IDFT
        x = np.fft.ifft(symbol)

        #Add cyclic prefix
        ofdmSym = np.concatenate((x[-self.Ncp:], x))

        return ofdmSym
    
    def Rx(self, rec_sym, H, H_f, channel_est_frame, pilot_loc, Xp, L, SNR, p1, p1_f):
        
        #Remove cyclic prefic
        y = rec_sym[self.Ncp:self.Nfft+self.Ncp]
        # DFT
  #fp    #
        V = FFT_quantize_22(y, 2) 
        V_f = np.fft.fft(y) 

        
        #Channel Estimation
        #H_est_LS, LS_MSE = self.LS_CE(V, Xp, pilot_loc, self.Nfft)
        
        #H_est_dft_LS, h_est_ls = self.DFT_CE(H_est_LS, L)
        
        #H_est_MSE = self.MSE_CE(pilot_loc, h_est_ls, SNR, LS_MSE)
        
        #H_est_dft, h_est_MSE = self.DFT_CE(H_est_MSE, L)

        #extract data
        data, pilot_after = self.data_extract(V, Xp, pilot_loc)
        data_f, pilot_after_f = self.data_extract(V_f, Xp, pilot_loc)

        pilot_eq = p1 * pilot_after
        pilot_eq_f = p1_f * pilot_after_f
        
   #fp    
        phase_offset = quantize_trunc(np.conj(np.average(quantize_trunc(pilot_eq * Xp[1:], 9))),9)
        phase_offset_f = np.conj(np.average(pilot_eq_f * Xp[1:]))

        
        #equalization
   #fp     #
        Y = channel_est_frame * quantize_trunc(np.conj(H),9) * data
        Y_f = channel_est_frame * np.conj(H_f) * data_f

        
        # Y = data / (H/channel_est_frame)
        #Demodulate Received Symbols - Demapping
   #fp   #
        detectedSyms = self.modem.demodulate(quantize_trunc(quantize_trunc(Y,9)*phase_offset, 9))
        detectedSyms_f = self.modem.demodulate(Y_f * phase_offset_f)

        return detectedSyms_f, detectedSyms_f, quantize_trunc(quantize_trunc(Y,9), 9), (Y_f * phase_offset_f)
    
    def ch_est(self, preamble, channel_est_frame, Xp, pilot_loc):
        
        preamblez = preamble[self.Ncp:self.Nfft+self.Ncp]
        #channel_est_frame = np.pad(channel_est_frame, (6, 5), mode='constant')
        
    #fp    
        preamble = FFT_quantize_22(preamblez, 2)
        preamble_f = np.fft.fft(preamblez)
        
        #H = preamble/channel_est_frame
                
        H, p1 = self.data_extract(preamble, Xp, pilot_loc)
        H_f, p1_f = self.data_extract(preamble_f, Xp, pilot_loc)

        channel_est_frame_data, p2 = self.data_extract(channel_est_frame, Xp, pilot_loc)
        
   #fp     # 
        pilot_eq = quantize_trunc(p2 * quantize_trunc(np.conj(p1),9), 9)
        pilot_eq_f = p2 * np.conj(p1_f)
        
    #fp    #
        return H, channel_est_frame_data, pilot_eq, pilot_eq_f, H_f
        # return H, channel_est_frame_data, pilot_eq
        
        
        
        
        
        
        
        
        
        
        
        