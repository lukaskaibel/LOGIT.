//
//  TimerTimeView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 01.04.22.
//

import SwiftUI

struct TimerTimeView: View {
    @StateObject var timer = TimerModel()
    
    @Binding var showingTimerView: Bool
    
    var body: some View {
        Group {
            if timer.isRunning || timer.isPaused {
                Text(timer.timeString)
                    .foregroundColor(timer.isRunning ? .accentColor : .secondaryLabel)
                    .font(.body.weight(.bold).monospacedDigit())
            } else {
                Image(systemName: "timer")
            }
        }
            .sheet(isPresented: $showingTimerView) {
                ZStack(alignment: .top) {
                    NavigationView {
                        TimerView(selectableSeconds: Array(stride(from: 15, to: 300, by: 15)))
                            .environmentObject(timer)
                            .navigationBarTitle("Set Timer")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: { showingTimerView = false }) {
                                        Text("Dismiss")
                                    }
                                }
                            }
                    }
                    Capsule()
                        .fill(Color.fill)
                        .frame(width: 35, height: 5)
                        .padding(.top, 7)
                }
            }
    }
    
}
