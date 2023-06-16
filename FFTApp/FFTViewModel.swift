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

            DispatchQueue.main.async {

                self.data = self.convertToChartPoints(
                    signal: SygnalManager.performFFT(
                        on: buffer,
                        metricsBlock: { frameCount, channelsCount, samlesCount, maxMagnitude in
                            self.frameCount = frameCount
                            self.channelsCount = channelsCount
                            self.samlesCount = samlesCount
                            self.maxMagnitude = maxMagnitude
                    }) ?? []
                )

            }
        }
    }

    private func convertToChartPoints(signal: [Float]) -> [ChartPoint] {
        var chartPoints: [ChartPoint] = []
        for (index, value) in signal.enumerated() {
            let chartPoint = ChartPoint(valueX: Float(index), valueY: value)
            chartPoints.append(chartPoint)
        }
        return chartPoints
    }

}
