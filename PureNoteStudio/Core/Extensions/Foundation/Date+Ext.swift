//
//  Date+Ext.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import Foundation

extension Date {
    var formattedDateString: String {
        let formatter = DateFormatter()
        let dayPassed = Calendar.current.dateComponents(Set([.day]), from: self, to: Date()).day ?? 0

        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "hh:mm a"
            return formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) {
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: self)
        } else if dayPassed < 6 {
            return self.formatted(.dateTime.weekday(.wide))
        } else {
            return self.formatted(.dateTime.month(.abbreviated).day(.twoDigits))
        }
    }
}
