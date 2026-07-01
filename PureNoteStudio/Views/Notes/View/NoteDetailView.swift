//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI

struct NoteDetailView: View {
    let note: Note
    var body: some View {
        Text(note.title)
    }
}
