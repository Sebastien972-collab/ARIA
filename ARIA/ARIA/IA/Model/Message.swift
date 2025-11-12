//
//  Message.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import Foundation

struct Message: Identifiable, Hashable {
    let id = UUID()
    let role: String
    var content: String
}

struct Prompt: Codable {
    let role: String
    let content: String
}

struct OllamaRequest: Codable {
    let model: String
    let messages: [Prompt]
}

struct OllamaStreamResponse: Codable {
    let model: String?
    let created_at: String?
    let message: StreamMessage?
    let response: String?
    let done: Bool

    var content: String {
        message?.content ?? response ?? ""
    }
}

struct StreamMessage: Codable {
    let role: String?
    let content: String?
}
