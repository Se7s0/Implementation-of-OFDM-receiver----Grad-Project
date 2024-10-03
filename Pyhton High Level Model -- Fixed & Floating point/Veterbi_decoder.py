import numpy as np


def vet_decoder(message, ns, out, Nstates):

            pm = np.zeros((Nstates,), dtype =int)
            
            modpm = np.copy(pm)
            dummy = np.copy(pm)
            dummy = np.transpose(dummy)
            
            av = np.transpose(np.copy(pm))
            av[0] = 1
            
            coding_rate = np.array([1,2])
            
            nbits = 2**coding_rate[0]
            
            #decimal_array = [int(''.join(map(str, message[i:i+2])), 2) for i in range(0, len(message), 2)]
            
            exp = message
            
            #exp = np.array([2, 1, 0, 2, 0, 1, 1, 2, 2, 2, 2, 2, 0, 1, 1, 1, 2, 2, 2, 1, 2, 0, 0, 1, 3, 0, 1, 3, 1, 1, 1, 2]) -- modified
            #exp = np.array([3, 1, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 2, 1, 3, 0, 0, 1, 3, 0, 1, 3, 1, 1, 1, 2]) -- true

            
            msg_out = np.zeros((Nstates,exp.size), dtype =int)
            msg_states = np.copy(msg_out)
            msg = np.copy(msg_out)
            
            for j in range(nbits):
                
                pm[ns[0,j]] = np.sum(np.array([int(x) for x in np.binary_repr(out[0,j],coding_rate[1])]) ^ \
                                     np.array([int(x) for x in np.binary_repr(exp[0],coding_rate[1])])) 
                msg_out[ns[0,j], 0] = out[0, j]
                msg_states[ns[0,j],0] = 0;
                msg[ns[0,j],0] = j;
                
            
            for k in range(1,exp.size,1):
                
                for i in range(Nstates):
                    
                    if av[i] == 1:
                        
                        for j in range(nbits):
                            
                            dummy[ns[i,j]] = 1;
            
                av  = av | dummy 
                modpm = np.zeros((Nstates,), dtype =int)
                oldpm = np.copy(pm)
                
                for i in range(Nstates):
                    
                    if(av[i]) == 1:
                        
                        for j in range(nbits):
                            
                            if modpm[ns[i,j]] == 0:
                                
                                pm[ns[i,j]] = oldpm[i] + np.sum(np.array([int(x) for x in np.binary_repr(out[i,j],coding_rate[1])]) ^ \
                                                                np.array([int(x) for x in np.binary_repr(exp[k],coding_rate[1])])) 
                                
                                modpm[ns[i,j]] = 1;
                                
                                msg_out[ns[i,j],k] = out[i,j]
                           
                                msg_states[ns[i,j],k] = i
                           
                                msg[ns[i,j],k] = j
                            
                            else:
                                
                                temp = oldpm[i] + np.sum(np.array([int(x) for x in np.binary_repr(out[i,j],coding_rate[1])]) ^ \
                                                         np.array([int(x) for x in np.binary_repr(exp[k],coding_rate[1])]))
                                
                                if temp < pm[ns[i,j]]:
                                    
                                    pm[ns[i,j]] = temp
                                    
                                    msg_out[ns[i,j],k] = out[i,j]
                               
                                    msg_states[ns[i,j],k] = i;
                               
                                    msg[ns[i,j],k] = j;
                                    
            
            for i in range(Nstates):
                
                if av[i] == 1:
                    
                    for j in range(nbits):
                        
                        dummy[ns[i,j]] = 1;
            
            av  = av | dummy
            
            av_pm =  np.vstack((av,pm,np.arange(0,pm.size,1,))).T
            
            av_pm_filtered = av_pm[av_pm[:, 0] != 0,:][:,-2:]
            
            match = av_pm_filtered[np.where(av_pm_filtered[:, 0] == np.min(av_pm_filtered[:, 0]))[0], 1]
                                    
            possible_matches = np.zeros((exp.size,),dtype = int)
            decoded = np.zeros((exp.size,),dtype = int)
            
            
            for I in range(match.size):
                    relac = msg_states[match[I],exp.size - 1]
                    decoded[exp.size - 1] = msg[match[I],exp.size - 1]
                    
                    for i in range(exp.size-2,-1,-1):
                        decoded[i] = msg[relac,i]
                        relac = msg_states[relac,i]
                    
                    possible_matches = np.vstack((possible_matches,decoded))   
            
            
            
            possible_matches = possible_matches[1:] 
            
            return possible_matches



                        
                        
                        
                        
                    

    


