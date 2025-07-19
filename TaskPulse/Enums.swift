// Enums.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation

enum Priority: String, Codable, CaseIterable {
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var sortOrder: Int {
        switch self {
        case .high:
            return 2
        case .medium:
            return 1
        case .low:
            return 0
        }
    }
} 