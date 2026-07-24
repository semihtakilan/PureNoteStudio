//
//  NotesTabCoordinator.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 23.07.2026.
//

import SwiftUI

struct NotesTabCoordinator: View {
    let appDependencies: AppDependencies
    
    @State private var viewModel: NotesViewModel
    @Environment(TabRouter.self)
    private var router
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        
        self._viewModel = State(
            initialValue: NotesViewModel(
                noteRepository: appDependencies.noteRepository,
                categoryRepository: appDependencies.categoryRepository
            )
        )
    }
    
    var body: some View {
        @Bindable var notesRouter = router.notesRouter
        @Bindable var bindableViewModel = viewModel
        
        NavigationStack(path: $notesRouter.path) {
            NotesView(viewModel: viewModel)
                .navigationDestination(for: NotesRoute.self) { route in
                    switch route {
                        
                    case .detail(let note):
                        NoteDetailView(
                            note: note,
                            noteRepository: appDependencies.noteRepository,
                            categoryRepository: appDependencies.categoryRepository,
                            notificationManager: appDependencies.notificationManager,
                            richTextService: appDependencies.richTextService
                        )
                        
                    case .folders:
                        FoldersView(
                            noteRepository: appDependencies.noteRepository,
                            categoryRepository: appDependencies.categoryRepository,
                            selectedItem: $bindableViewModel.selectedFilter
                        )
                        
                    case .moveToFolder(let note):
                        MoveToFolder(
                            note: note,
                            categoryRepository: appDependencies.categoryRepository
                        )
                    }
                }
                .sheet(item: $notesRouter.presentedSheet) { item in
                    switch item {
                    case .addNote:
                        AddNoteSheet(
                            noteRepository: appDependencies.noteRepository,
                            richTextService: appDependencies.richTextService
                        )
                        .onDisappear {
                            viewModel.load()
                        }
                    }
                }
        }
        .environment(router.notesRouter)
    }
}
