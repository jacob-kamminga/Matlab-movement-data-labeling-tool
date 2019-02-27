function entropy = calcEntropy(FFT,window_size)
entropy = 0;
        
        % v = FrameSignal' .* hann(length(FrameSignal)); 
        

        %N = length(v);
        %winSize = N; %?????
        %Y=fft(v);
        Y=FFT;

        % Compute the Power Spectrum
        sqrtPyy = ((sqrt(abs(Y).*abs(Y)) * 2 )/window_size);
        sqrtPyy = sqrtPyy(1:floor(window_size/2));



       %Normalization
       d=sqrtPyy(:);
       d=d/sum(d+ 1e-12);

       %Entropy Calculation
       logd = log2(d + 1e-12);
      entropy = -sum(d.*logd)/log2(length(d));
