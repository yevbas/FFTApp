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
    @State private var maxXValue: Float? = nil
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Chart {
                    ForEach(viewModel.data) { chartPoint in
                        LineMark(
                            x: .value("\(chartPoint.valueX)", chartPoint.valueX),
                            y: .value("\(chartPoint.valueY)",
                                      chartPoint.valueY)
                        )
                        .foregroundStyle(.black)
                        .annotation(position: .topLeading, alignment: .center) {
                            if let maxPoint = viewModel.data.max(by: { $0.valueY < $1.valueY }) {
                                Text(String.init(
                                    format: "%.2f", maxPoint.valueX)
                                )
                                .foregroundColor(.orange)
                                .font(.caption2)
                                .bold()
                            }
                        }
                    }

                }
                .animation(.default, value: viewModel.data)
                .padding()
                
                Group {
                    Text("Max magnitude: \(viewModel.maxMagnitude)")
                    Text("Samples count: \(viewModel.samlesCount)")
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Button(action: {
                    viewModel.isPausePressed.toggle()
                }) {
                    Text(viewModel.isPausePressed ? "Start" : "Pause")
                        .foregroundColor(.purple)
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FFTSygnalControlView()
    }
}
