// Enums.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation

enum Priority: String, Codable, CaseIterable, Comparable {
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var sortOrder: Int {
        switch self {
        case .high:
            return 3
        case .medium:
            return 2
        case .low:
            return 1
        }
    }
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}