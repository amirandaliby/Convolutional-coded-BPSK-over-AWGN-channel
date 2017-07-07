%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%             convolutional coded BPSK over awgn CH.                    %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all

datasize=2048;      %length of main data 
M=2;                %assigning the M-ary for psk modulation

frame=3000;          %number of frames for monte carlo loop

SNR1=0:1:5;%assigning the value of snr in decibels
SNR=10.^(SNR1/10);%converting the snr db value to snr

trellis = poly2trellis(3,[7 5]); % Define trellis  

for SNRloop=1:length(SNR1)
        error=0;
        for jj=1:frame;%MONTE CARLO LOOP
%--------------------------------TRANSMITTER---------------------------------------------------------------------------

%---------------generating data------------
        msg=randint(1,datasize,M);

%-----------convolutional coding-------------
        code = convenc(msg,trellis); % convolutional Encoding

%------interleaving----------
        intrlvcode=randintrlv(code,4831);

%-----------PSK modulation------------------
        modul=modem.pskmod('M',2,'PhaseOffset',0,'SymbolOrder','gray','InputType','integer');%definng the 8-psk modulator objec
        y=modulate(modul,intrlvcode);%modulate with the input

%---------------------------channel----------------------------------------
    %GENERATING NOISE
        Sigma=sqrt(1./(0.5*2*SNR(SNRloop)*log2(M)));
        Noise=Sigma*(randn(1,length(y))+1j*randn(1,length(y)));
      
        ytr=Noise+y;     %transmitted signal

%--------------------------------RECEIVER--------------------------------- 
%-----------PSK de-modulation------------------
        demodul=modem.pskdemod('M',2,'PhaseOffset',0,'SymbolOrder','gray');%defining the 8 psk demodulator object
        demod=demodulate(demodul,ytr);%perform demodulation

%-----------deinterleaving--------------------
        deintrlvdemod=randdeintrlv(demod,4831);

%-----------convolutional decoding-------------      
        decoded = vitdec(deintrlvdemod, trellis, 100, 'trunc', 'soft',1);
%--------------------------------------------------------------------------------------------------------------


error=error+sum(msg~=decoded);%comparing the error in the data received to the input

       end
err(SNRloop)=error/(datasize*log2(M)*frame);
end


%computing BER performance in AWGN
%ThBER=0.5*erfc(sqrt(SNR));

%plotting the results
%semilogy(SNR1,ThBER);
%hold on
semilogy(SNR1,err,'ro-');
xlabel('SNR in dB')
ylabel('Bir error rate')
title('Bit error rate vs SNR')
grid on
