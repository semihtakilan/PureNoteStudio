//
//  ChipView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

struct ChipView: View {
    let items: [CategoryFilter]
    @Binding var selectedItem: CategoryFilter?
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                HStack {
                    ForEach(items) { item in
                        let isSelected = item.id == selectedItem?.id
                        Button {
                            selectedItem = item
                        }
                        label: {
                            Text(item.name)
                        }
                        .padding(8)
                        .padding(.horizontal, 8)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .background(isSelected ? Color(.systemBlue) : Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .id(item.name)
                    }
                }
                .onChange(of: selectedItem?.name) { _, newValue in
                    if let newName = newValue {
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(0.1))
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                                proxy.scrollTo(newName, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .scrollIndicators(.hidden)
    }
}
