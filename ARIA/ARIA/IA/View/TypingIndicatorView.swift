//
//  TypingIndicatorView.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import SwiftUI

struct TypingIndicator: View {
    @State private var dots = ""

    var body: some View {
        Text("ARIA réfléchit\(dots)")
            .italic()
            .foregroundColor(.gray)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                    dots = dots.count < 3 ? dots + "." : ""
                }
            }
    }
}

#Preview {
    TypingIndicator()
}
