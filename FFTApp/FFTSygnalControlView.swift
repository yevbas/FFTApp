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

//struct FFTSygnalControlView: View {
//    @ObservedObject var viewModel: FFTViewModel = FFTViewModel()
//
//    //    var biggestX: Double {
//    //        Double(viewModel.data.max(by: { $0.valueX < $1.valueX })?.valueX ?? 0)
//    //    }
//
////    let timer = Timer.publish(every: 0.025, on: .main, in: .common).autoconnect()
//
//    var biggestYValue: Float? {
//        viewModel.data.max(by: { $0.valueY < $1.valueY })?.valueY
//    }
//
//
//    var body: some View {
//        GeometryReader { proxy in
//            VStack {
//                Chart {
//                    ForEach(viewModel.data) { chartPoint in
//                        LineMark(
//                            x: .value("\(chartPoint.valueX)", chartPoint.valueX),
//                            y: .value("\(chartPoint.valueY)", chartPoint.valueY)
//                        )
//                        .foregroundStyle(.white)
//                    }
//                }
//                .padding()
//
//                Group {
//                    Text("Frame Count: \(viewModel.frameCount)")
//                    Text("Max magnitude: \(viewModel.maxMagnitude)")
//                    Text("Samples count: \(viewModel.samlesCount)")
//
//                    // Calculate the maximum Y value and its corresponding X value
//                    if let maxPoint = viewModel.data.max(by: { $0.valueY < $1.valueY }) {
//                        Text("Max Y: \(maxPoint.valueY), X: \(maxPoint.valueX)")
//                    }
//                }
//                .foregroundColor(.yellow)
//
//                Spacer()
//
//                Button(action: {
//                    viewModel.isPausePressed.toggle()
//                }) {
//                    Text(viewModel.isPausePressed ? "Start" : "Pause")
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .background(Color.gray)
////        .onReceive(timer) { _ in
////            // Perform necessary updates here at 25ms interval
////
////            // Update the view model or perform any other actions
////            withAnimation {
////
////            }
////        }
//    }
//}

//import SwiftUI

//import SwiftUI

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
