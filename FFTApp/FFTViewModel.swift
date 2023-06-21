//
//  FFTViewModel.swift
//  TermometerApp
//
//  Created by Basistyi, Yevhen on 25/05/2023.
//

import SwiftUI

class FFTViewModel: ObservableObject {

    private let sygnalManager = SygnalManager()

    @Published var maxMagnitude: Float = 0.0
    @Published var frameCount: Int = 0
    @Published var samlesCount = 0
    @Published var channelsCount = 0

    @Published var data: [ChartPoint] = []
    
    private var frequencyResolution: Float = 0.0

    @Published var isPausePressed: Bool = true {
        didSet {
            if isPausePressed {
                sygnalManager.stopObservingInputSygnal()
            } else {
                sygnalManager.startObservingInputSygnal()
            }
        }
    }

    init() {
        startSimulation()
    }

    func startSimulation() {
        sygnalManager.setupAudioEngine { [weak self] buffer, time in
            guard let self else { return }

            self.frequencyResolution = Float(buffer.format.sampleRate) / Float(buffer.frameLength)
            
            DispatchQueue.main.async {

                self.data = self.convertToChartPoints(
                    signal: SygnalManager.performFFT(
                        on: buffer,
                        metricsBlock: { frameCount, channelsCount, samlesCount, maxMagnitude, frequencyResolution  in
                            self.frameCount = frameCount
                            self.channelsCount = channelsCount
                            self.samlesCount = samlesCount
                            self.maxMagnitude = maxMagnitude
                            self.frequencyResolution = frequencyResolution
                    }) ?? []
                )

            }
        }
    }

    private func convertToChartPoints(signal: [Float]) -> [ChartPoint] {
        var chartPoints: [ChartPoint] = []
        for (index, value) in signal.enumerated() {
            
            let frequency = Float(index) * self.frequencyResolution
            
            #warning("ADDITIONAL FILTERING RULES: ")
            if value > 0.012, frequency < 15000 {
                let chartPoint = ChartPoint(
                    valueX: frequency,
                    valueY: value < 0.2 ? 0.0 : value >= 1.5 ? 1.5 : value
                )
                chartPoints.append(chartPoint)
            }
        }
        
        chartPoints.append(.init(valueX: 10000, valueY: 0.0))
        return chartPoints
    }


}
