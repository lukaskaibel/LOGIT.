//
//  ViewModel.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 17.04.22.
//

import Foundation

/// Provides a base for the view models in the project, that automatically publishes its objectWillChange publisher when the shared Database has changed.
class ViewModel: ObservableObject {
    
    internal let database = Database.shared
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView),
                                               name: .databaseDidChange,
                                               object: nil)
    }
    
    @objc func updateView() {
        objectWillChange.send()
    }
    
}
