//
//  NotesTabView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 23.07.2026.
//

import SwiftUI

struct NotesTabView: View {
    @Bindable var viewModel: NotesViewModel
    
    @Environment(TabRouter.self)
    private var router
    
    var body: some View {
        @Bindable var notesRouter = router.notesRouter
        
        NavigationStack(path: $notesRouter.path) {
            NotesView(viewModel: viewModel)
                .navigationDestination(for: NotesRoute.self) { route in
                    switch route {
                        
                    case .detail(let note):
                        NoteDetailView(
                            note: note
                        )
                        
                    case .folders:
                        FoldersView(
                            onFilterSelected: viewModel.selectFilter
                        )
                        
                    case .moveToFolder(let note):
                        MoveToFolder(
                            note: note
                        )
                    }
                }
                .sheet(item: $notesRouter.presentedSheet) { item in
                    switch item {
                    case .addNote:
                        AddNoteSheet()
                        .onDisappear {
                            viewModel.load()
                        }
                    }
                }
        }
        .environment(router.notesRouter)
    }
}
