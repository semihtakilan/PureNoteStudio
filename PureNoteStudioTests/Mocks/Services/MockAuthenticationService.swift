//
//  MockAuthenticationService.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import Foundation
@testable import PureNoteStudio

final class MockAuthenticationService: AuthenticationService {
    
    var mockCanEvaluate: Bool = true
    var mockAuthenticationSuccess: Bool = true
    
    private(set) var canEvaluateCallCount = 0
    private(set) var authenticateCallCount = 0
    private(set) var capturedReason: String?
    
    func canEvaluatePolicy() -> Bool {
        canEvaluateCallCount += 1
        return mockCanEvaluate
    }
    
    func authenticate(reason: String) async -> Bool {
        authenticateCallCount += 1
        capturedReason = reason
        return mockAuthenticationSuccess
    }
}
