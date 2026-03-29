//
//  DateFormatters+Extensions.swift
//  ImageFeed
//
//  Created by bot on 24.02.2026.
//
import Foundation

// MARK: - ISO8601DateFormatter
extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}

// MARK: - DateFormatter
extension DateFormatter {
    static let imageList: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
}
