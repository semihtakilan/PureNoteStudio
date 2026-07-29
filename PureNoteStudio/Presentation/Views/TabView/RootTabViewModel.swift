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
    
    @ObservationIgnored
    @AppStorage("faceIDState") private var faceIDState: Bool = true
    var isUnlocked: Bool = false
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
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
