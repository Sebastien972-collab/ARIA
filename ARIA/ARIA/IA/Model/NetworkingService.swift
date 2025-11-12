//
//  NetworkingService.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import Foundation

final class NetworkingService {
    static let shared = NetworkingService()
    private init() {}

    func requestFullResponse(endpoint: String, body: Data) async throws -> String {
        let baseURL = "https://lusterless-nondisingenuously-selina.ngrok-free.dev"
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // On récupère toutes les lignes JSON renvoyées par Ollama
        let lines = String(data: data, encoding: .utf8)?
            .split(separator: "\n")
            .compactMap { String($0) } ?? []

        // On concatène tout le texte contenu dans chaque ligne
        var finalResponse = ""

        for line in lines {
            guard let jsonData = line.data(using: .utf8) else { continue }
            if let decoded = try? JSONDecoder().decode(OllamaStreamResponse.self, from: jsonData) {
                if decoded.done { break }
                finalResponse += decoded.content
            }
        }

        if finalResponse.isEmpty {
            throw URLError(.cannotParseResponse)
        }

        return finalResponse.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
