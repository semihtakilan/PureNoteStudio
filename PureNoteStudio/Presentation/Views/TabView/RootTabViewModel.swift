//
//  RootTabViewModel.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 27.07.2026.
//

import SwiftUI

@Observable
final class RootTabViewModel {
    
    private let authService: AuthenticationServiceProtocol

    private let defaults = UserDefaults.standard
    private let faceIDKey = "faceIDState"
    
    @ObservationIgnored
    @AppStorage("faceIDState") private var faceIDState: Bool = true
    var isUnlocked: Bool = false
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
        
        if defaults.object(forKey: faceIDKey) == nil {
            defaults.set(true, forKey: faceIDKey)
        }
        
        let faceIDEnabled = defaults.bool(forKey: faceIDKey)
        
        self.isUnlocked = !faceIDEnabled
    }
    
    func authenticate() {
        Task {
            if faceIDState {
                if authService.canEvaluatePolicy() {
                    let reason = "We need to unlock your data."
                    let success = await authService.authenticate(reason: reason)
                    
                    if success {
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                self.isUnlocked = true
                            }
                        }
                    }
                }
            } else {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isUnlocked = true
                    }
                }
            }
        }
    }
}
