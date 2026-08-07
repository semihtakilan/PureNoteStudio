//
//  SettingsViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 27.07.2026.
//

import SwiftUI

@Observable
final class SettingsViewModel {
    private let authService: AuthenticationService
    
    private let defaults = UserDefaults.standard
    private let faceIDKey = "faceIDState"
    
    var isFaceIDEnabled: Bool
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    init(authService: AuthenticationService) {
        self.authService = authService
        if defaults.object(forKey: faceIDKey) == nil {
            defaults.set(false, forKey: faceIDKey)
        }
        self.isFaceIDEnabled = defaults.bool(forKey: faceIDKey)
        print("SettingsViewModel")
    }
    
    func toggleFaceID(isOn: Bool) {
        guard isOn else {
            defaults.set(false, forKey: faceIDKey)
            self.isFaceIDEnabled = false
            return
        }
        
        withAnimation {
            self.isFaceIDEnabled = true
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            
            if authService.canEvaluatePolicy() {
                let reason = "Face ID'yi etkinleştirmek için cihaz sahibi olduğunuzu doğrulayın."
                let success = await authService.authenticate(reason: reason)
                
                await MainActor.run {
                    if success {
                        self.defaults.set(true, forKey: self.faceIDKey)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    } else {
                        withAnimation { self.isFaceIDEnabled = false }
                    }
                }
            } else {
                await MainActor.run {
                    withAnimation { self.isFaceIDEnabled = false }
                    self.alertMessage = "Face ID kullanabilmek için cihaz ayarlarından izin vermeniz veya Face ID'yi kurmanız gerekmektedir."
                    self.showAlert = true
                }
            }
        }
    }
}
