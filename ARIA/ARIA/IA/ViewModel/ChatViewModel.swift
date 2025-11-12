//
//  ChatViewModel.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var userInput: String = ""
    var isProcessing = false
    private let service = NetworkingService.shared

    func sendMessage() {
        guard !userInput.isEmpty else { return }

        let userMessage = Message(role: "user", content: userInput)
        messages.append(userMessage)
        let promptText = userInput
        userInput.removeAll()
        isProcessing = true

        let requestBody = OllamaRequest(
            model: "mistral",
            messages: [
                Prompt(
                    role: "system",
                    content: """
                    Tu es ARIA, une IA intégrée dans une application iOS.
                    Réponds toujours en français, de manière claire et naturelle.
                    """
                ),
                Prompt(role: "user", content: promptText)
            ]
        )

        guard let encodedBody = try? JSONEncoder().encode(requestBody) else { return }

        Task {
            do {
                let fullResponse = try await service.requestFullResponse(
                    endpoint: "/api/chat",
                    body: encodedBody
                )
                await MainActor.run {
                    self.messages.append(Message(role: "assistant", content: fullResponse))
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.messages.append(
                        Message(role: "assistant", content: "Erreur réseau : \(error.localizedDescription)")
                    )
                    self.isProcessing = false
                }
            }
        }
    }

    func scanRoom() {
        messages.append(Message(role: "system", content: "🔍 Analyse de la pièce en cours..."))
    }
}
