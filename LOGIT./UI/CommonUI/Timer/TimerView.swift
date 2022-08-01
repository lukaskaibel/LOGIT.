//
//  TimerView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 29.03.22.
//

import SwiftUI

struct TimerView: View {
    
    @EnvironmentObject var timerModel: TimerModel
    @State private var animationAmount = 1.0
    let selectableSeconds: [Int]
    
    init(selectableSeconds: [Int]) {
        self.selectableSeconds = selectableSeconds
    }
        
    var body: some View {
        VStack {
            if timerModel.isRunning || timerModel.isPaused {
                Text(timerModel.timeString)
                    .foregroundColor(.label)
                    .font(.system(size: 80, weight: .light).monospacedDigit())
                    .padding(60)
                    .frame(maxHeight: 350)
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 8)
                                .foregroundColor(.fill)
                            Circle()
                                .trim(from: 0, to: timerModel.progress)
                                .stroke(style: StrokeStyle(lineWidth: 8,
                                                           lineCap: .round,
                                                           lineJoin: .round))
                                .animation(.linear(duration: 0.1), value: animationAmount)
                                .foregroundColor(.accentColor)
                                .rotationEffect(Angle(degrees: -90))
                        }.frame(maxWidth: 350, maxHeight: 350)
                    }
                    .padding(.vertical, 20)
            } else {
                VStack {
                    Picker(NSLocalizedString("selectDuration", comment: ""), selection: $timerModel.duration) {
                        ForEach(selectableSeconds, id:\.self) { i in
                            Text(String(i)).tag(i)
                        }
                    }.pickerStyle(.wheel)
                        .frame(maxWidth: 300, maxHeight: 350)
                        .overlay {
                            HStack {
                                Image(systemName: "timer")
                                Spacer()
                                Text(NSLocalizedString("sec", comment: ""))
                            }//.font(.body.weight(.semibold))
                                .foregroundColor(.label)
                                .padding()
                        }
                }.padding(.vertical, 20)
            }
            HStack {
                Button(action: {
                    timerModel.reset()
                }) {
                    Text(NSLocalizedString("cancel", comment: ""))
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.label.opacity(0.8))
                        .padding(28)
                        .background(Color.secondaryBackground)
                        .clipShape(Circle())
                        .padding(3)
                        .background {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(.secondaryBackground)
                        }
                }
                Spacer()
                Button(action: {
                    if timerModel.isRunning {
                        timerModel.stop()
                    } else {
                        timerModel.start()
                    }
                }) {
                    Text(timerModel.isRunning ? NSLocalizedString("stop", comment: "") : NSLocalizedString("start", comment: ""))
                        .foregroundColor(timerModel.isRunning ? .white : .accentColor)
                        .font(.footnote.weight(.semibold))
                        .padding(28)
                        .background(Color.accentColor.opacity(timerModel.isRunning ? 1.0 : 0.2))
                        .clipShape(Circle())
                        .padding(3)
                        .background {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(Color.accentColor.opacity(timerModel.isRunning ? 1.0 : 0.2))
                        }
                }
            }.padding(.horizontal)
            Spacer()
        }
    }
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(selectableSeconds: Array(1...300))
            .environmentObject(TimerModel())
    }
}
