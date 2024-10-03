from Modem import *
from theoretical_SER import *
from basic_channels import *

def test_awgn(nSym, EbN0dBs, mod_type, arrayOfM):

    modem_dict = {'psk': PSKModem,'qam':QAMModem,'pam':PAMModem}

    SER_sim = []
    SER_theo = []
    
    for M in arrayOfM:
        
        k = np.log2(M)
        EsN0dBs = 10 * np.log10(k) + EbN0dBs  # EsN0dB calculation
        ser_sim = np.zeros(len(EbN0dBs))  # simulated Symbol error rates
        inputSyms = np.random.randint(low=0, high=M, size=nSym)  # uniform random symbols from 0 to M-1

        modem = modem_dict[mod_type.lower()](M)  

        modulatedSyms = modem.modulate(inputSyms)  

        for j, EsN0dB in enumerate(EsN0dBs):
            receivedSyms = awgn(modulatedSyms, EsN0dB)  # transmit through awgn channel

            detectedSyms = modem.demodulate(receivedSyms)

            ser_sim[j] = np.sum(detectedSyms != inputSyms) / nSym

        SER_sim.append(ser_sim)
        SER_theo.append(ser_awgn(EbN0dBs, mod_type, M))  # theory SER

    SER_sim = np.array(SER_sim)
    SER_theo = np.array(SER_theo)

    return SER_sim, SER_theo


def test_rayleigh(nSym, EbN0dBs, mod_type, arrayOfM):

    modem_dict = {'psk': PSKModem,'qam':QAMModem,'pam':PAMModem}

    SER_sim = []
    SER_theo = []
    
    for M in arrayOfM:
        
        k = np.log2(M)
        EsN0dBs = 10 * np.log10(k) + EbN0dBs  # EsN0dB calculation
        ser_sim = np.zeros(len(EbN0dBs))  # simulated Symbol error rates
        inputSyms = np.random.randint(low=0, high=M, size=nSym)  # uniform random symbols from 0 to M-1

        modem = modem_dict[mod_type.lower()](M)  

        modulatedSyms = modem.modulate(inputSyms)  

        for j, EsN0dB in enumerate(EsN0dBs):

            h_abs = rayleighFading(nSym) #Rayleigh flat fading samples
            hs = h_abs*modulatedSyms #fading effect on modulated symbols
            
            receivedSyms = awgn(hs,EsN0dB) #add awgn noise
            y = receivedSyms/h_abs # decision vector

            detectedSyms = modem.demodulate(y)

            ser_sim[j] = np.sum(detectedSyms != inputSyms) / nSym

        SER_sim.append(ser_sim)
        SER_theo.append(ser_rayleigh(EbN0dBs, mod_type, M))  # theory SER

    SER_sim = np.array(SER_sim)
    SER_theo = np.array(SER_theo)

    return SER_sim, SER_theo

def test_rician(nSym, EbN0dBs, mod_type, M, K_dBs):

    modem_dict = {'psk': PSKModem,'qam':QAMModem,'pam':PAMModem}

    SER_sim = []
    SER_theo = []
    
    for K_dB in K_dBs:
        
        k = np.log2(M)
        EsN0dBs = 10 * np.log10(k) + EbN0dBs  # EsN0dB calculation
        ser_sim = np.zeros(len(EbN0dBs))  # simulated Symbol error rates
        inputSyms = np.random.randint(low=0, high=M, size=nSym)  # uniform random symbols from 0 to M-1

        modem = modem_dict[mod_type.lower()](M)  

        modulatedSyms = modem.modulate(inputSyms)  

        for j, EsN0dB in enumerate(EsN0dBs):

            h_abs = ricianFading(K_dB, nSym) #Rayleigh flat fading samples
            hs = h_abs*modulatedSyms #fading effect on modulated symbols
            
            receivedSyms = awgn(hs,EsN0dB) #add awgn noise
            y = receivedSyms/h_abs # decision vector

            detectedSyms = modem.demodulate(y)

            ser_sim[j] = np.sum(detectedSyms != inputSyms) / nSym

        SER_sim.append(ser_sim)
        SER_theo.append(ser_rician(K_dB, EbN0dBs, mod_type, M))  # theory SER

    SER_sim = np.array(SER_sim)
    SER_theo = np.array(SER_theo)

    return SER_sim, SER_theo