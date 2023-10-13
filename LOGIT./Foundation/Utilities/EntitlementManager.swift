//
//  EntitlementManager.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 13.10.23.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "com.lukaskbl.LOGIT")!

    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
