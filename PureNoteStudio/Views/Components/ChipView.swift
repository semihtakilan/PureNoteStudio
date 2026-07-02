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
    var isSelected: Bool
    private(set) var createdOn: Date
    
    init(name: String, isSelected: Bool, createdOn: Date) {
        self.name = name
        self.isSelected = isSelected
        self.createdOn = createdOn
    }

//    view model'de yapılacak TAŞI
    static func convertCategoryToChipData(category: Category) -> ChipData {
        return .init(name: category.name, isSelected: category.isSelected, createdOn: category.createdOn)
    }
    
    static func fetchAll(from categories: [Category]) -> [ChipData] {
        var chipDatas: [ChipData] = []
        
        for category in categories {
            chipDatas.append(self.convertCategoryToChipData(category: category))
        }
        
        return chipDatas
    }
}

struct ChipView: View {
    @Binding var allDatas: [ChipData]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(allDatas) { data in
                    Button {
                        chipSelected(data)
                    } label: {
                        Text(data.name)
                    }
                    .padding(8)
                    .padding(.horizontal, 8)
                    .font(.subheadline)
                    .foregroundStyle(data.isSelected ? .white : .primary)
                    .background(data.isSelected ? Color(.systemBlue) : Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                               
                }
            }
        }
        .scrollIndicators(.hidden)
    

    }
    
//    mantığı yanlış
    func chipSelected(_ selected: ChipData) {
        for index in allDatas.indices {
            if selected.id != allDatas[index].id {
                allDatas[index].isSelected = false
            } else {
                allDatas[index].isSelected.toggle()
            }
        }
        
    }
    
}

