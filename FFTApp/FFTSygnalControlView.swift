//
//  ContentView.swift
//  TermometerApp
//
//  Created by Basistyi, Yevhen on 30/03/2023.
//

import SwiftUI
import Charts

struct ChartPoint: Identifiable, Equatable {
    var id = UUID()

    var valueX: Float
    var valueY: Float
}

struct FFTSygnalControlView: View {
    @ObservedObject var viewModel: FFTViewModel = FFTViewModel()

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Chart {
                    ForEach(viewModel.data) { chartPoint in
                        LineMark(
                            x: .value("\(chartPoint.valueX)", chartPoint.valueX),
                            y: .value("\(chartPoint.valueY)", chartPoint.valueY)
                        )
                        .foregroundStyle(.white)
                    }
                }
                .padding()

                Group {
                    Text("Frame Count: \(viewModel.frameCount)")
                    Text("Max magnitude: \(viewModel.maxMagnitude)")
                    Text("Samples count: \(viewModel.samlesCount)")
                }
                .foregroundColor(.yellow)
                
                Spacer()

                Button(action: {
                    viewModel.isPausePressed.toggle()
                }) {
                    Text(viewModel.isPausePressed ? "Start" : "Pause")
                        .foregroundColor(.black)
                }
            }
        }
        .background(Color.gray)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FFTSygnalControlView()
    }
}
