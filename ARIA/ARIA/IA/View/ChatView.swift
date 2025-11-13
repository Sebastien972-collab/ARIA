//
//  ChatView.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var showScanner = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if showScanner {
                VStack{
                    headerView
                    Divider()
                    scannerView
                }
            } else {
                VStack{
                    headerView
                    
                    Divider()
                    ChatView
                }
            }
            Button {
                withAnimation {
                    showScanner.toggle()
                }
            } label: {
                Image(systemName: showScanner ? "message.fill" : "camera.viewfinder")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding(.leading,16)
            .padding(.bottom,10)
        }
    }
    
    private var headerView: some View {
            HStack{
                
                Spacer()
                
                Text(showScanner ? "Scanner" : "Chat")
                    .font(.headline)
                
                Spacer()
                
            }
            .padding(.vertical,8)
            .background(Color(.systemBackground))
            
            
        
    }
    
    private var ChatView: some View{
        VStack {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
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
                            .id(message.id)
                        }
                        
                        // Indicateur de saisie / traitement
                        if viewModel.isProcessing {
                            TypingIndicator()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .id("TypingIndicator")
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        // Quand un nouveau message arrive → scroll vers le bas
                        withAnimation {
                            if viewModel.isProcessing {
                                proxy.scrollTo("TypingIndicator", anchor: .bottom)
                            } else if let lastId = viewModel.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isProcessing) { _, newValue in
                        if newValue {
                            withAnimation {
                                proxy.scrollTo("TypingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }
                .defaultScrollAnchor(.bottom)
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
        }
    }
    
    private var scannerView: some View {
        VStack{
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.3))
                .padding(.bottom, 20)
            
            Text("Scanner la pièce")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            Text("Utilisez RoomPlan pour scanner votre espace")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
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
            if viewModel.capturedRoom != nil {
                HStack{
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Pièce scannée avec succès")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top,20)
            }
            Spacer()
        }
        //                .animation(.easeInOut, value: viewModel.messages)
        //                .animation(.easeInOut, value: viewModel.isProcessing)
        .sheet(isPresented: $viewModel.scanRoomViewIsPresented) {
            RoomScanView { room in
                viewModel.capturedRoom = room
                viewModel.scanRoomViewIsPresented = false
                withAnimation {
                    showScanner = false
                }
            }
        }
    
    }
    
}

