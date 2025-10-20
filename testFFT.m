num_iter = 10000;
times = zeros(num_iter, 1);

for iter = 1:num_iter

    tic
    
    n = 6;
    number = 1234567473;
    bitmap = logical(reshape(dec2bin(number,36)-'0',6,6)');
    
    autocorr_fft = uint8(real(ifft2(conj(fft2(bitmap)).*fft2(bitmap))));
    
    times(iter) = toc;

end

fprintf("Average time over 10000 iterations was %.8f\n", mean(times))