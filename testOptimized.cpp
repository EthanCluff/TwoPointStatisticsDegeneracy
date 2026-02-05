// testOptimized.cpp
// Compile: g++ -O3 testOptimized.cpp -lfftw3 -o testOptimized
// Run: ./testOptimized

#include <fftw3.h>
#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <algorithm>

int main() {
    const int side_length = 6;                // matches your MATLAB side_length
    const int N = side_length * side_length;
    const std::size_t num_trials = 1000000;   // 1e6, same as MATLAB

    // RNG: fixed seed for repeatability (change or random_device if you want non-deterministic)
    std::mt19937_64 rng(123456789ULL);
    std::uniform_real_distribution<double> uni(0.0, 1.0);

    // Allocate FFTW arrays (complex-to-complex)
    fftw_complex* in  = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * N);
    fftw_complex* F   = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * N);
    fftw_complex* tmp = (fftw_complex*)fftw_malloc(sizeof(fftw_complex) * N);

    if (!in || !F || !tmp) {
        std::cerr << "FFTW allocation failed\n";
        return 1;
    }

    // Create FFTW plans once for this size. Reusing plans is a standard optimization
    // and does NOT assume the same input; it only depends on the transform size.
    fftw_plan plan_fwd = fftw_plan_dft_2d(
        side_length, side_length, in, F, FFTW_FORWARD, FFTW_MEASURE);

    fftw_plan plan_back = fftw_plan_dft_2d(
        side_length, side_length, tmp, in, FFTW_BACKWARD, FFTW_MEASURE);

    if (!plan_fwd || !plan_back) {
        std::cerr << "FFTW plan creation failed\n";
        fftw_free(in); fftw_free(F); fftw_free(tmp);
        return 1;
    }

    // Buffer for the final autocorrelation (uint8 per your MATLAB)
    std::vector<uint8_t> autocorr(N);

    // We'll time only the kernel: generate microstructure, compute FFT, power, ifft, real, round->uint8
    auto t0 = std::chrono::high_resolution_clock::now();

    for (std::size_t t = 0; t < num_trials; ++t) {
        // 1) Generate microstructure (logical(round(rand() - 0.25)))
        // MATLAB: r = rand() - 0.25; value = logical(round(r));
        for (int i = 0; i < N; ++i) {
            double r = std::round(uni(rng) - 0.25);
            double v = (r != 0.0) ? 1.0 : 0.0;
            in[i][0] = v;  // real part
            in[i][1] = 0.0; // imag part
        }

        // 2) Forward FFT: in -> F
        fftw_execute(plan_fwd);

        // 3) Compute power spectrum: tmp = conj(F) .* F = a^2 + b^2 (real), imag = 0
        for (int i = 0; i < N; ++i) {
            double a = F[i][0];
            double b = F[i][1];
            tmp[i][0] = a * a + b * b; // real part
            tmp[i][1] = 0.0;           // imag part
        }

        // 4) Inverse FFT: tmp -> in
        fftw_execute(plan_back);

        // 5) Normalize by N (FFTW's backward transform is unnormalized)
        //    Take real part, round to nearest integer, clamp to [0,255], cast to uint8_t
        for (int i = 0; i < N; ++i) {
            double val = in[i][0] / static_cast<double>(N); // expected integer counts
            long rounded = lround(val);                     // round to nearest integer
            if (rounded < 0) rounded = 0;
            if (rounded > 255) rounded = 255;
            autocorr[i] = static_cast<uint8_t>(rounded);
        }

        // Note: we reuse buffers to avoid per-iteration heap allocs (realistic optimized C++).
        // Crucially, we recompute the FFT of the *current* microstructure every iteration,
        // so we're NOT relying on precomputing an FFT across iterations.
    }

    auto t1 = std::chrono::high_resolution_clock::now();
    double elapsed = std::chrono::duration<double>(t1 - t0).count();
    double time_per_eval = elapsed / static_cast<double>(num_trials);

    std::cout << "Time per evaluation: " << std::scientific << time_per_eval << " seconds\n";
    std::cout << "Estimated time for 1e6 runs: " << (time_per_eval * 1e6) << " seconds\n";

    // Optional: print first autocorr to verify (uncomment if you want)
    // std::cout << "Sample autocorr (first row): ";
    // for (int j = 0; j < side_length; ++j) std::cout << (int)autocorr[j] << " ";
    // std::cout << "\n";

    // cleanup
    fftw_destroy_plan(plan_fwd);
    fftw_destroy_plan(plan_back);
    fftw_free(in);
    fftw_free(F);
    fftw_free(tmp);

    return 0;
}
