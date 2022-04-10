//
//  Timer.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 31.03.22.
//

import SwiftUI

final class TimerModel: ObservableObject {
    
    @Published public var duration = 15
    
    private weak var timer: Timer?
    private var startDate: Date?
    private var timeValueWhenStopped: Double?
    
    public static var shared = TimerModel()
    
    public var isRunning: Bool {
        startDate != nil
    }
    
    public var isPaused: Bool {
        timeValueWhenStopped != nil
    }
        
    public var timeString: String {
        let time = Int(remainingTime ?? 0)
        return "\(time/60 / 10 % 6 )\(time/60 % 10):\(time % 60 / 10)\(time % 60 % 10)"
    }
    
    public var progress: Double {
        1 - (remainingTime ?? 0) / Double(duration)
    }
    
    public func setDuration(to duration: Int) {
        self.duration = duration
    }
    
    public func start() {
        startDate = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateView()
        }
        updateView()
    }
    
    public func stop() {
        timeValueWhenStopped = remainingTime
        startDate = nil
        timer?.invalidate()
        objectWillChange.send()
    }
    
    public func reset() {
        timer?.invalidate()
        startDate = nil
        timeValueWhenStopped = nil
        objectWillChange.send()
    }
    
    private var remainingTime: Double? {
        guard let startDate = startDate else {
            return timeValueWhenStopped
        }
        return (timeValueWhenStopped ?? Double(duration)) - Double(Date.now.timeIntervalSince(startDate))
    }
    
    @objc private func updateView() {
        if remainingTime ?? 0 <= 0 {
            reset()
        }
        objectWillChange.send()
    }
    
}
