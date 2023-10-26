//
//  ScanScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 26.10.23.
//

import SwiftUI
import Combine
import Camera_SwiftUI
import AVFoundation

struct ScanScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var scanModel = ScanModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    cancelButton
                    Spacer()
                    if scanModel.photo == nil {
                        flashButton
                    }
                }
                .padding(.horizontal)
                Spacer()
                Group {
                    if let image = scanModel.photo?.image {
                        Image(uiImage: image)
                            .resizable()
                            
                            .scaledToFit()
                    } else {
                        cameraPreview
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Group {
                    if let image = scanModel.photo?.image {
                        HStack {
                            Button {
                                scanModel.photo = nil
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .buttonStyle(SecondaryBigButtonStyle())
                            .frame(width: 50)
                            Button {
                                
                            } label: {
                                Label("Generate Workout", systemImage: "gearshape.2.fill")
                            }
                            .buttonStyle(BigButtonStyle())
                        }
                    } else {
                        captureButton
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Supporting Views
    
    private var flashButton: some View {
        Button(action: {
            scanModel.switchFlash()
        }, label: {
            Image(systemName: scanModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 20, weight: .medium, design: .default))
        })
        .accentColor(scanModel.isFlashOn ? .yellow : .white)
    }
    
    private var captureButton: some View {
        Button(action: {
            scanModel.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    
    private var cameraPreview: some View {
        CameraPreview(session: scanModel.session)
            .onAppear {
                scanModel.configure()
            }
            .alert(isPresented: $scanModel.showAlertError, content: {
                Alert(title: Text(scanModel.alertError.title), message: Text(scanModel.alertError.message), dismissButton: .default(Text(scanModel.alertError.primaryButtonTitle), action: {
                    scanModel.alertError.primaryAction?()
                }))
            })
            .overlay(
                Group {
                    if scanModel.willCapturePhoto {
                        Color.black
                    }
                }
            )
            .animation(.easeInOut)
    }
    
    private var cancelButton: some View {
        Button(NSLocalizedString("cancel", comment: "")) {
            dismiss()
        }
    }
    
}

private final class ScanModel: ObservableObject {
    
    private let service = CameraService()
    
    @Published var photo: Photo?
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
}

#Preview {
    ScanScreen()
}
