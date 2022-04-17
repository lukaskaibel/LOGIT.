//
//  ViewModel.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 17.04.22.
//

import Foundation

class ViewModel: ObservableObject {
    
    internal let database = Database.shared
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .databaseDidChange, object: nil)
    }
    
    @objc func updateView() {
        objectWillChange.send()
    }
    
}
