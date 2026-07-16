//
//  ChipView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

struct ChipData: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

struct ChipView: View {
    let chipDatas: [ChipData]
    @Binding var selectedChip: ChipData?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(chipDatas) { chip in
                    let isSelected = chip.id == selectedChip?.id
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
                               
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
