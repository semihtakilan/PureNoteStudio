//
//  AuthenticationService.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import Foundation
import LocalAuthentication

protocol AuthenticationService {
    func canEvaluatePolicy() -> Bool
    func authenticate(reason: String) async -> Bool
}

struct AuthenticationServiceLive: AuthenticationService {
    
    func canEvaluatePolicy() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch {
            print("Authentication failed: \(error.localizedDescription)")
            return false
        }
    }
}
