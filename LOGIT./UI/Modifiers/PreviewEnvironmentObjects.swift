//
//  PreviewEnvironmentObjects.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 16.10.23.
//

import SwiftUI

struct PreviewEnvironmentObjects: ViewModifier {
    
    @StateObject private var database: Database
    @StateObject private var templateService: TemplateService
    @StateObject private var measurementController: MeasurementEntryController
    @StateObject private var purchaseManager: PurchaseManager
    @StateObject private var networkMonitor: NetworkMonitor
    
    init() {
        let db = Database(isPreview: true)
        _database = StateObject(wrappedValue: db)
        _templateService = StateObject(wrappedValue: TemplateService(database: db))
        _measurementController = StateObject(wrappedValue: MeasurementEntryController(database: db))
        _purchaseManager = StateObject(wrappedValue: PurchaseManager())
        _networkMonitor = StateObject(wrappedValue: NetworkMonitor())
    }

    func body(content: Content) -> some View {
        content
            .environmentObject(database)
            .environmentObject(templateService)
            .environmentObject(measurementController)
            .environmentObject(purchaseManager)
            .environmentObject(networkMonitor)
            .task {
                Task {
                    do {
                        try await purchaseManager.loadProducts()
                    } catch {
                        print(error)
                    }
                }
            }
    }
}

extension View {
    func previewEnvironmentObjects() -> some View {
        modifier(PreviewEnvironmentObjects())
    }
}
