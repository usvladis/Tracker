//
//  DaysFormatter.swift
//  Tracker
//
//  Created by Владислав Усачев on 27.09.2024.
//

import Foundation

struct DaysFormatter {
    func formatDays(_ count: Int) -> String {
        let locale = Locale.current
        let languageCode = locale.languageCode ?? "en"
        
        switch languageCode {
        case "ru":
            return formatDaysInRussian(count)
        default:
            return formatDaysInEnglish(count)
        }
    }
    
    // Форматируем строку для русского языка
    private func formatDaysInRussian(_ count: Int) -> String {
        switch count {
        case 0:
            return NSLocalizedString("days_format_zero", comment: "")
        default:
            let lastDigit = count % 10
            let lastTwoDigits = count % 100
            
            if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
                return String.localizedStringWithFormat(NSLocalizedString("days_format_many", comment: ""), count)
            } else if lastDigit == 1 {
                return String.localizedStringWithFormat(NSLocalizedString("days_format", comment: ""), count)
            } else if lastDigit >= 2 && lastDigit <= 4 {
                return String.localizedStringWithFormat(NSLocalizedString("days_format_plural", comment: ""), count)
            } else {
                return String.localizedStringWithFormat(NSLocalizedString("days_format_many", comment: ""), count)
            }
        }
    }
    
    // Форматируем строку для английского языка
    private func formatDaysInEnglish(_ count: Int) -> String {
        switch count {
        case 0:
            return NSLocalizedString("days_format_zero", comment: "")
        case 1:
            return String.localizedStringWithFormat(NSLocalizedString("days_format", comment: ""), count)
        default:
            return String.localizedStringWithFormat(NSLocalizedString("days_format_plural", comment: ""), count)
        }
    }
}
