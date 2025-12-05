function autocorr = Calculate_Two_Point_Statistics_Fourier(microstructure)
    autocorr = real(ifft2(conj(fft2(microstructure)).*fft2(microstructure)));
end