//
//  ChipView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 1.07.2026.
//

import SwiftUI

struct ChipData: Identifiable {
    var id: UUID = UUID()
    var name: String
    private(set) var createdOn: Date
    
    init(name: String, createdOn: Date) {
        self.name = name
        self.createdOn = createdOn
    }
}

struct ChipView: View {
    let chipDatas: [ChipData]
    let selectedChip: ChipData?
    let onSelect: (ChipData) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(chipDatas) { chip in
                    let isSelected = chip.id == selectedChip?.id
                    Button {
                        onSelect(chip)
                    } label: {
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

