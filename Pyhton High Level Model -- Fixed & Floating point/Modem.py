import numpy as np
import matplotlib.pyplot as plt

from abc import ABC 
from scipy.spatial.distance import cdist

class Modem(ABC): #Abstract Base Class

    def __init__(self, M, constellation,name) -> None:
        super().__init__()

        if (M<2) or ((M & (M -1))!=0): #if M not a power of 2
            raise ValueError('M should be a power of 2')
        
        self.M = M # Modulation order
        self.name = name # name of the modem 
        self.constellation = constellation # ideal reference constellation

    def plot_constellation(self):

        fig, axs = plt.subplots(1, 1)
        axs.plot(np.real(self.constellation),np.imag(self.constellation),'o')
        for i in range(0,self.M):
            axs.annotate("{0:0{1}b}".format(i,self.M),(np.real(self.constellation[i]),np.imag(self.constellation[i])))
        
        axs.set_title('Constellation')
        axs.set_xlabel('I')
        axs.set_ylabel('Q')
        fig.show()

    def modulate(self, inputSymbols):
        """
        Modulate a vector of input symbols (numpy array format) using the
        chosen modem. Input symbols take integer values in the range 0 to M-1.
        """
        if isinstance(inputSymbols,list):
            inputSymbols = np.array(inputSymbols)

        if not (0 <= inputSymbols.all() <= self.M-1):
            raise ValueError('inputSymbols values are beyond the range 0 to M-1')

        modulatedVec = self.constellation[inputSymbols] 

        return modulatedVec 

    def iqDetector(self, receivedSyms):
        """
        Optimum Detector for 2-dim. signals (ex: MQAM,MPSK,MPAM) in IQ Plane
        Note: MPAM/BPSK are one dimensional modulations. The same function can be
        applied for these modulations since quadrature is zero (Q=0)

        The function computes the pair-wise Euclidean distance of each point in the
        received vector against every point in the reference constellation. It then
        returns the symbols from the reference constellation that provide the
        minimum Euclidean distance.

        Parameters:
            receivedSyms : received symbol vector of complex form

        Returns:
            detectedSyms : decoded symbols that provide minimum Euclidean distance
        """
        # received vector and reference in cartesian form
        XA = np.column_stack((np.real(receivedSyms),np.imag(receivedSyms)))
        XB=np.column_stack((np.real(self.constellation),np.imag(self.constellation)))

        d = cdist(XA,XB,metric='euclidean') #compute pair-wise Euclidean distances
        detectedSyms=np.argmin(d,axis=1)#indices corresponding minimum Euclid. dist.

        return detectedSyms
    
    def demodulate(self, receivedSyms):
        
        if isinstance(receivedSyms,list):
            receivedSyms = np.array(receivedSyms)

        detectedSyms= self.iqDetector(receivedSyms)
        
        return detectedSyms


class PAMModem(Modem):
    # Derived class: PAMModem
    def __init__(self, M):

        m = np.arange(0,M) 
        constellation = 2*m+1-M 

        Modem.__init__(self, M, constellation, name='PAM') 


class PSKModem(Modem):
    # Derived class: PSKModem
    def __init__(self, M):
        
        m = np.arange(0,M) #
        I = 1/np.sqrt(2)*np.cos(m/M*2*np.pi)
        Q = 1/np.sqrt(2)*np.sin(m/M*2*np.pi)

        constellation = I + 1j*Q 

        Modem.__init__(self,M, constellation, name='PSK') 


class QAMModem(Modem):
    # Derived class: QAMModem
    def __init__(self,M):
        if (M==1) or (np.mod(np.log2(M),2)!=0): # M not a even power of 2
            raise ValueError('Only square MQAM supported. M must be even power of 2')
        
        D = int(np.sqrt(M))
        d = np.arange(0,D)

        I = 2*d+1-D
        Q = 2*d+1-D

        I_grid, Q_grid = np.meshgrid(I, Q)
        constellation = I_grid + 1j*Q_grid
        constellation *= 1/np.sqrt(2*(M-1)/3)

        constellation = constellation.ravel()

        Modem.__init__(self, M, constellation, name='QAM')

        
