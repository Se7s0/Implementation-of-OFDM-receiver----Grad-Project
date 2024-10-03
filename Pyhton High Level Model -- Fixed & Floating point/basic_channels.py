import numpy as np
from numpy.random import standard_normal

def awgn(s,SNRdB):
    """
    AWGN channel

    Add AWGN noise to input signal. The function adds AWGN noise vector to signal
    's' to generate a resulting signal vector 'r' of specified SNR in dB. It also
    returns the noise vector 'n' that is added to the signal 's' and the power
    spectral density N0 of noise added

    Parameters:
    s : input/transmitted signal vector
        SNRdB : desired signal to noise ratio (expressed in dB)
    
    Returns:
        r : received signal vector (r=s+n)
    """

    gamma = 10**(SNRdB/10) #SNR to linear scale

    if s.ndim==1:# if s is single dimensional vector
        P = sum(abs(s)**2)/len(s) #power in the vector
    else: # multi-dimensional signal
        P = sum(sum(abs(s)**2))/len(s) 

    N0=P/gamma 

    if np.isrealobj(s):# check if input is real/complex object type
        n = np.sqrt(N0/2)*standard_normal(s.shape) # computed noise
    else:
        n = np.sqrt(N0/2)*(standard_normal(s.shape)+1j*standard_normal(s.shape))

    r = s + n # received signal

    return r


def rayleighFading(N):
    """
    Generate Rayleigh flat-fading channel samples

    Parameters:
        N : number of samples to generate

    Returns:
        abs_h : Rayleigh flat fading samples
    """
    # 1 tap complex gaussian filter , white so no time variance
    h = 1/np.sqrt(2)*(standard_normal(N)+1j*standard_normal(N))
    return np.abs(h)

def ricianFading(K_dB,N):
    """
    Generate Rician flat-fading channel samples

    Parameters:
        K_dB: Rician K factor in dB scale
        N : number of samples to generate
    Returns:
        abs_h : Rician flat fading samples
    """

    K = 10**(K_dB/10) # K factor in linear scale

    mu = np.sqrt(K/(2*(K+1))) 
    sigma = np.sqrt(1/(2*(K+1))) 

    h = (sigma*standard_normal(N)+mu)+1j*(sigma*standard_normal(N)+mu)

    return abs(h)