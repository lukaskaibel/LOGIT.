//
//  TimerView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 08.06.23.
//

import SwiftUI

struct TimerView: View {
    
    @ObservedObject var timer: TimerModel
    
    var body: some View {
        HStack {
            if timer.isRunning || timer.isPaused {
                HStack {
                    HStack {
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.interactiveSpring()) {
                                timer.isRunning ? timer.stop() : timer.start()
                            }
                        } label: {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .font(.title2.weight(.heavy))
                                .padding()
                                .background(Color.accentColor.opacity(0.25))
                                .clipShape(Circle())
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            timer.reset()
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .font(.title2.weight(.heavy))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.fill)
                                .clipShape(Circle())

                        }
                    }
                    Spacer()
                    Text(timer.remainingTimeString)
                        .font(.system(size: 60).monospacedDigit())
                        .foregroundColor(.accentColor)
                }
                .padding()
            } else {
                VStack {
                    HStack {
                        Text(NSLocalizedString("timer", comment: ""))
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text(NSLocalizedString("selectDuration", comment: ""))
                            .foregroundColor(.secondaryLabel)
                    }
                    .padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(values, id:\.self) { time in
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    timer.remainingSeconds = time + 1
                                    timer.start()
                                } label: {
                                    Text("\(time/60 / 10 % 6 )\(time/60 % 10):\(time % 60 / 10)\(time % 60 % 10)")
                                        .font(.title3.weight(.medium))
                                        .padding(10)
                                        .background(Color.accentColor.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private let values = [10, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 480, 540, 600]
    
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timer: TimerModel())
    }
}
