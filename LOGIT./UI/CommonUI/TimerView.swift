//
//  TimerView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 29.03.22.
//

import SwiftUI

struct TimerView: View {
    
    let selectableSeconds: [Int]
    
    @State private var startTime: Date?
    @State private var selectedTime = 1
    @State private var timerString: String? = nil
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if isRunning, let timerString = timerString {
                Text(timerString)
                    .font(.system(size: 60, weight: .medium, design: .default).monospacedDigit())
                    .padding(40)
                    .frame(maxHeight: 350)
                    .overlay {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 5)
                                .foregroundColor(.fill)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.accentColor)
                                .rotationEffect(Angle(degrees: -90))
                        }.frame(maxWidth: 350, maxHeight: 350)
                    }
            } else {
                VStack {
                    Picker("Select Duration", selection: $selectedTime) {
                        ForEach(selectableSeconds, id:\.self) { i in
                            Text(String(i)).tag(i)
                        }
                    }.pickerStyle(.wheel)
                        .frame(maxHeight: 350)
                    Button(action: {
                        startTime = Date()
                    }) {
                        Text("start")
                    }
                }
            }
        }
            .onReceive(timer) { _ in
                withAnimation(.linear(duration: 1.0)) {
                    setTimerString()
                }
            }
    }
    
    private var progress: CGFloat {
        1 - CGFloat(timerTime! - 1) / CGFloat(selectedTime)
    }
    
    private var timerTime: Int? {
        guard let startTime = startTime else { return nil }
        let time = selectedTime - Int(NSInteger(Date.now.timeIntervalSince(startTime)) % 60)
        if time < 0 {
            self.startTime = nil
            return nil
        } else {
            return time
        }

    }
    
    private func setTimerString() {
        timerString = timerTime == nil ? nil : "\(timerTime!/60 / 10 % 6 )\(timerTime!/60 % 10):\(timerTime! % 60 / 10)\(timerTime! % 60 % 10)"
    }
        
    private var isRunning: Bool {
        startTime != nil
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(selectableSeconds: Array(1...300))
    }
}
