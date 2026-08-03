//
//  NotificationManager.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 22.07.2026.
//

import Foundation
import UserNotifications

final class NotificationManagerLive: NotificationManager {

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Bildirim izni alınırken hata oluştu: \(error)")
            return false
        }
    }
    
    func scheduleNotification(title: String, body: String, date: Date) async throws -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        
        content.body = String(body.prefix(100)) + (body.count > 100 ? "..." : "")
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let requestID = UUID().uuidString
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
        
        return requestID
    }
    
    func removeNotification(with id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
