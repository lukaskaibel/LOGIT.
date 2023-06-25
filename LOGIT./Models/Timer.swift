//
//  Timer.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 31.03.22.
//

import SwiftUI

final class TimerModel: ObservableObject {
    private weak var timer: Timer?
        
    private var timeValueWhenStopped: Int?
    
    private var duration: Int = 0
        
        
    public var isRunning: Bool { endDate != nil }
    
    public var isPaused: Bool { timeValueWhenStopped != nil }
    
    public var onTimerFired: () -> Void = {}
    
    public var preventTimerFromFiring: Bool = false
    
    public var remainingSeconds: Int {
        get { remainingTime }
        set {
            guard newValue > 0 else { reset(); return }
            endDate = .now.addingTimeInterval(TimeInterval(newValue))
            duration = newValue
            updateView()
        }
    }
    
    public var endDate: Date?
    
    public var remainingTimeString: String {
        "\(remainingSeconds/60 / 10 % 6 )\(remainingSeconds/60 % 10):\(remainingSeconds % 60 / 10)\(remainingSeconds % 60 % 10)"
    }
    
    
    public func start() {
        if let timeValueWhenStopped = timeValueWhenStopped {
            endDate = Date.now.addingTimeInterval(TimeInterval(timeValueWhenStopped))
        } else {
            guard duration != 0 else { return }
            endDate = Date.now.addingTimeInterval(TimeInterval(duration))
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateView()
        }
        updateView()
    }
    
    public func stop() {
        timeValueWhenStopped = remainingTime
        endDate = nil
        timer?.invalidate()
        objectWillChange.send()
    }
    
    public func reset() {
        timer?.invalidate()
        endDate = nil
        duration = 0
        timeValueWhenStopped = nil
        objectWillChange.send()
    }
    
    
    private var remainingTime: Int {
        guard isRunning else { return timeValueWhenStopped ?? 0 }
        return Int(endDate!.timeIntervalSince(.now))
    }
    
    @objc private func updateView() {
        if remainingTime <= 0 {
            reset()
            if !preventTimerFromFiring {
                onTimerFired()
            }
        }
        objectWillChange.send()
    }
    
}
