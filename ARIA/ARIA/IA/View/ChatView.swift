//
//  ChatView.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // Messages
            ScrollView {
                ForEach(viewModel.messages) { message in
                    HStack {
                        if message.role == "assistant" {
                            Text("🤖 \(message.content)")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else if message.role == "system" {
                            Text(message.content)
                                .italic()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Text(message.content)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }

                // Indicateur de saisie / traitement
                if viewModel.isProcessing {
                    TypingIndicator()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
            }
            
            Divider()

            // Barre d'entrée utilisateur
            HStack {
                TextField("Écris un message...", text: $viewModel.userInput)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isProcessing)
                
                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(viewModel.userInput.isEmpty ? .gray : .blue)
                        .padding(8)
                }
                .disabled(viewModel.userInput.isEmpty || viewModel.isProcessing)
            }
            .padding()

            // Bouton "Scanner la pièce"
            Button {
                viewModel.scanRoom()
            } label: {
                Label("Scanner la pièce", systemImage: "camera.viewfinder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
        .animation(.easeInOut, value: viewModel.messages)
        .animation(.easeInOut, value: viewModel.isProcessing)
    }
}
