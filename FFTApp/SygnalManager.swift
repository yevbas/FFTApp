//
//  SygnalManager.swift
//  TermometerApp
//
//  Created by Basistyi, Yevhen on 15/06/2023.
//

import Foundation
import Accelerate
import AVFoundation

final class SygnalManager {
    private let audioEngine: AVAudioEngine

    init(audioEngine: AVAudioEngine = .init()) {
        self.audioEngine = audioEngine
    }

     func setupAudioEngine(block: @escaping AVAudioNodeTapBlock) {
        // Set up the audio input node
        let inputNode = audioEngine.inputNode

        // Set up the audio format for the input
        let inputFormat = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat, block: block)
    }

    func startObservingInputSygnal() {
        // Start the audio engine
        do {
            try audioEngine.start()
        } catch {
            // Handle any errors
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func convertBufferToFloatArray(buffer: AVAudioPCMBuffer) -> [Float]? {
        // Get the number of channels in the buffer
        let channelCount = Int(buffer.format.channelCount)

        // Get the total frame count of the buffer
        let frameCount = Int(buffer.frameLength)

        // Create an array to hold the converted float data
        var floatArray = [Float]()

        // Iterate over each channel and convert the buffer data to float
        for channel in 0..<channelCount {
            let channelData = buffer.floatChannelData![channel]

            for frame in 0..<frameCount {
                let floatSample = channelData[frame]
                floatArray.append(floatSample)
            }
        }

        return floatArray
    }

    func stopObservingInputSygnal() {
        audioEngine.stop()
    }

}

// MARK: FFT performing

extension SygnalManager {

    typealias FrameCount = Int
    typealias ChannelCount = Int
    typealias SamplesCount = Int
    typealias MaxMagnitude = Float

    static func performFFT(on buffer: AVAudioPCMBuffer,
                           metricsBlock: @escaping (FrameCount, ChannelCount, SamplesCount, MaxMagnitude) -> Void
    ) -> [Float]? {
        // Check if the buffer contains float channel data
        guard let floatChannelData = buffer.floatChannelData else {
            return nil
        }

        // Get the channel count, frame count, and sample count from the buffer
        let channelCount = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        let sampleCount = channelCount * frameCount

        // Create an array to store the float samples
        var floatSamples = [Float](repeating: 0.0, count: sampleCount)

        // Convert the float channel data to a flat array of samples
        for channel in 0..<channelCount {
            let channelData = floatChannelData[channel]
            for frame in 0..<frameCount {
                floatSamples[channel * frameCount + frame] = channelData[frame]
            }
        }

        // Calculate the size of the FFT buffer
        let log2n = vDSP_Length(log2(Float(frameCount)))
        let fftSize = vDSP_Length(1 << log2n)
        let bufferSize = Int(fftSize)

        // Create arrays to store the magnitudes and imaginary parts
        var magnitudes = [Float](repeating: 0.0, count: bufferSize)
        var imaginary = [Float](repeating: 0.0, count: bufferSize)

        // Use the float samples as the real part of the complex buffer
        var real = floatSamples

        // Create a DSPSplitComplex object from the real and imaginary arrays
        var complexBuffer = DSPSplitComplex(realp: &real, imagp: &imaginary)

        // Create an FFT setup object
        let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))

        // Perform the FFT on the complex buffer
        vDSP_fft_zip(fftSetup!, &complexBuffer, 1, log2n, FFTDirection(FFT_FORWARD))

        // Destroy the FFT setup object
        vDSP_destroy_fftsetup(fftSetup)

        // Calculate the magnitudes of the complex values
        vDSP_zvabs(&complexBuffer, 1, &magnitudes, 1, vDSP_Length(bufferSize / 2))

        // Scale the magnitudes by a factor of 4.0 / bufferSize
        var scalingFactor = 4.0 / Float(bufferSize)
        vDSP_vsmul(magnitudes, 1, &scalingFactor, &magnitudes, 1, vDSP_Length(bufferSize / 2))

        metricsBlock(frameCount, channelCount, sampleCount, magnitudes.max() ?? 0.0)

        return magnitudes
    }
}
