//
//  File.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 23.07.2026.
//

import SwiftUI

struct OverlayButton: View {
    var imageName: String
    var onTab: () -> Void
    
    var body: some View {
        Button {
            onTab()
        } label: {
            Image(systemName: imageName)
        }
        .padding(10)
        .font(.system(size: 20))
        .bold()
        .foregroundColor(.white)
        .background(Color(.systemBlue))
        .clipShape(Circle())
        .padding(.trailing, 16)
        .padding(.bottom, 16)

    }
}
