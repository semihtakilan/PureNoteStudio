//
//  ChipView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

struct ChipData: Equatable, Identifiable {
    let id: UUID = UUID()
    let name: String
}

struct ChipView: View {
    let chipDatas: [ChipData]
    @Binding var selectedChip: ChipData?
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                HStack {
                    ForEach(chipDatas) { chip in
                        let isSelected = chip.name == selectedChip?.name
                        Button {
                            selectedChip = chip
                        }
                        label: {
                            Text(chip.name)
                        }
                        .padding(8)
                        .padding(.horizontal, 8)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .background(isSelected ? Color(.systemBlue) : Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .id(chip.name)
                    }
                }
                .onChange(of: selectedChip?.name) { _, newValue in
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
