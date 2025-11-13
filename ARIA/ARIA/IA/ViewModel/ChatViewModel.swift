//
//  ChatViewModel.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import Foundation
import RoomPlan

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var userInput: String = ""
    var isProcessing = false
    var scanRoomViewIsPresented: Bool = false
    var capturedRoom: CapturedRoom?
    private let service = NetworkingService.shared

    func sendMessage() {
        guard !userInput.isEmpty else { return }

        let userMessage = Message(role: "user", content: userInput)
        messages.append(userMessage)
        let promptText = userInput
        userInput.removeAll()
        isProcessing = true
        var prompts: [Prompt] = [
            Prompt(
                role: "system",
                content: """
                Tu es ARIA, une IA intégrée dans une application iOS.
                Réponds toujours en français, de manière claire et naturelle.
                Si un plan de pièce est fourni, analyse-le pour répondre de manière contextuelle.
                """
            ),
            Prompt(role: "user", content: promptText)
        ]

        if let capturedRoom = capturedRoom,
           let jsonString = capturedRoom.toJSONString() {
            let roomPrompt = Prompt(
                role: "system",
                content: "Voici la pièce scannée en JSON :\n\(jsonString)"
            )
            prompts.insert(roomPrompt, at: 1)
        }

        let requestBody = OllamaRequest(model: "mistral", messages: prompts)

        guard let encodedBody = try? JSONEncoder().encode(requestBody) else {
            print("Erreur encodage requête.")
            return
        }

        // 5️⃣ Appel réseau
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
        scanRoomViewIsPresented.toggle()
    }
}
