//
//  RoomScanCoordinator.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import UIKit
import RoomPlan

final class RoomCaptureViewController: UIViewController, RoomCaptureSessionDelegate {
    private let roomCaptureView = RoomCaptureView()
    private let config = RoomCaptureSession.Configuration()
    private var latestRoom: CapturedRoom?          // ← cache de la frame courante

    var onFinish: ((CapturedRoom) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Vue RoomPlan
        roomCaptureView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roomCaptureView)
        NSLayoutConstraint.activate([
            roomCaptureView.topAnchor.constraint(equalTo: view.topAnchor),
            roomCaptureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            roomCaptureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            roomCaptureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Bouton "Enregistrer la pièce"
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Enregistrer la pièce", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        saveButton.layer.cornerRadius = 12
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 220),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Démarrage de la capture
        if let session = roomCaptureView.captureSession {
            session.delegate = self
            session.run(configuration: config)
        } else {
            print("❌ captureSession indisponible (nil).")
        }
    }

    // Tap = sauvegarder la dernière frame connue
    @objc private func saveTapped() {
        print("✅ Enregistrement de la frame courante…")
        guard let snapshot = latestRoom else {
            print("⚠️ Aucune frame disponible encore. Scanne quelques secondes puis réessaie.")
            return
        }
        handleCapturedRoom(snapshot)
        // Optionnel : arrêter ensuite la session
        roomCaptureView.captureSession?.stop()
        dismiss(animated: true)
    }

    // Mise à jour en continu : on met simplement à jour le cache
    func captureSession(_ session: RoomCaptureSession, didUpdate capturedRoom: CapturedRoom) {
        latestRoom = capturedRoom
    }

    // Fin “naturelle” de la session : on peut aussi en profiter
    func captureSession(_ session: RoomCaptureSession,
                        didEndWith capturedRoom: CapturedRoom,
                        error: (any Error)?) {
        guard error == nil else {
            print("❌ RoomPlan error:", error!.localizedDescription)
            return
        }
        latestRoom = capturedRoom
        // Si tu veux aussi terminer automatiquement dans ce cas :
        // handleCapturedRoom(capturedRoom)
        // dismiss(animated: true)
    }

    // Export + callback SwiftUI
    private func handleCapturedRoom(_ capturedRoom: CapturedRoom) {
        // Retour SwiftUI
        onFinish?(capturedRoom)

        // Export USDZ (optionnel)
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("RoomPlan.usdz")
            try capturedRoom.export(to: url)
            print("💾 USDZ enregistré :", url.path)
        } catch {
            print("❌ Erreur export USDZ :", error.localizedDescription)
        }

        // Dump JSON (optionnel, pour debug / API)
        if let json = capturedRoom.toJSONString() {
            print("🧩 JSON:\n\(json)")
        }
    }
}

import SwiftUI
import RoomPlan

struct RoomScanView: UIViewControllerRepresentable {
    var onFinish: (CapturedRoom) -> Void

    func makeUIViewController(context: Context) -> RoomCaptureViewController {
        let controller = RoomCaptureViewController()
        controller.onFinish = onFinish
        return controller
    }

    func updateUIViewController(_ uiViewController: RoomCaptureViewController, context: Context) {}
}
