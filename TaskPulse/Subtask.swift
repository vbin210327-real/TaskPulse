// Subtask.swift
// TaskPulse
//
// Created by AI Assistant.

import Foundation

struct Subtask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var completed: Bool = false
} 