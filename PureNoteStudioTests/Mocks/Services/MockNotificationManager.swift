//
//  MockNotificationManager.swift
//  PureNoteStudioTests
//
//  Created by Semih TAKILAN on 28.07.2026.
//

import Foundation
@testable import PureNoteStudio

final class MockNotificationManager: NotificationManager {
    
    var mockAuthorizationResult: Bool = false
    var mockScheduleNotificationID: String? = nil
    
    private(set) var requestAuthCallCount = 0
    
    private(set) var scheduleNotificationCallCount = 0
    private(set) var scheduleNotificationCapturedTitle: String?
    private(set) var scheduleNotificationCapturedBody: String?
    private(set) var scheduleNotificationCapturedDate: Date?
    
    private(set) var removeNotificationCallCount = 0
    private(set) var removeNotificationCapturedID: String?
    
    func requestAuthorization() async -> Bool {
        requestAuthCallCount += 1
        return mockAuthorizationResult
    }
    
    func scheduleNotification(
        title: String,
        body: String,
        date: Date
    ) -> String? {
        scheduleNotificationCallCount += 1
        scheduleNotificationCapturedTitle = title
        scheduleNotificationCapturedBody = body
        scheduleNotificationCapturedDate = date
        return mockScheduleNotificationID
    }
    
    func removeNotification(with id: String) {
        removeNotificationCallCount += 1
        removeNotificationCapturedID = id
    }
    
    
}
