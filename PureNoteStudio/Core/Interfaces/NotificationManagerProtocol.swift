//
//  NotificationManager.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 23.07.2026.
//

import Foundation

protocol NotificationManager {
    func requestAuthorization() async -> Bool
    func scheduleNotification(title: String, body: String, date: Date) -> String?
    func removeNotification(with id: String)
}
