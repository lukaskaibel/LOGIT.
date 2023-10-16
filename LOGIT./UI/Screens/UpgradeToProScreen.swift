//
//  UpgradeToProScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 14.09.23.
//

import SwiftUI

struct UpgradeToProScreen: View {
    
    // MARK: - Environment
    
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Capsule()
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 5)
                    .padding(.top)
                VStack(spacing: SECTION_SPACING) {
                    LogitProLogo()
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 50) {
                        VStack {
                            HStack(spacing: 30) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading) {
                                    Text("Visualise".uppercased())
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text("Charts")
                                        .font(.title3.weight(.bold))
                                    Text("From weight to reps, volume, and sets – visualize every step of your fitness journey!")
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        VStack {
                            HStack(spacing: 30) {
                                Image(systemName: "ruler")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading) {
                                    Text("Track More".uppercased())
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text("Measurements")
                                        .font(.title3.weight(.bold))
                                    Text("Plot bodyweight, calories, and measurements to clearly mark your progress.")
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        VStack {
                            HStack(spacing: 30) {
                                Image(systemName: "camera")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading) {
                                    Text("Save time".uppercased())
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text("Scan a Workout")
                                        .font(.title3.weight(.bold))
                                    Text("Convert a photo into a workout template instantly and start working out in seconds!")
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.leading, 25)
                    .padding(.trailing)
                }
            }
            .padding(.bottom, 200)
        }
        .overlay {
            VStack(spacing: 20) {
                HStack {
                    Text("Pricing")
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(purchaseManager.products.first?.displayPrice ?? "")
                            .font(.body.weight(.semibold))
                        Text("/ Month")
                            .font(.footnote.weight(.semibold))
                    }
                }
                Button {
                    Task {
                        do {
                            guard let product = purchaseManager.products.first else {
                                // TODO: Show Alert that error during purchase
                                return
                            }
                            try await purchaseManager.purchase(product)
                        } catch {
                            // TODO: Show Alert for Error during purchase
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to")
                        LogitProLogo()
                            .environment(\.colorScheme, .light)
                    }
                }
                .buttonStyle(BigButtonStyle())
                Button {
                    Task {
                        do {
                            try await purchaseManager.restorePurchase()
                        } catch {
                            // TODO: Show Alert for Restore Purchase failed
                        }
                    }
                } label: {
                    Text("Restore Purchase")
                }
            }
            .padding()
            .background {
                Rectangle()
                    .foregroundStyle(.thinMaterial)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onChange(of: purchaseManager.hasUnlockedPro) { newValue in
            if newValue {
                dismiss()
            }
        }
    }

}

struct UpgradeToProScreen_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeToProScreen()
            .environmentObject(PurchaseManager(entitlementManager: EntitlementManager()))
    }
}
