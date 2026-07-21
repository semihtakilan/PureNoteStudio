//
//  Collection+Ext.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 20.07.2026.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }

    func get(_ index: Index) -> Element? {
        self[safe: index]
    }
}
