//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI

struct NoteDetailView: View {
    let note: Note
    
    @Environment(AppDependencies.self)
    private var dependencies
    
    @State private var viewModel: NoteDetailViewModel?
    
    var body: some View {
        Group {
            if let viewModel {
                NoteDetailContentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = NoteDetailViewModel(
                    note: note,
                    noteRepository: dependencies.noteRepository,
                    notificationSchedulerLive: dependencies.notificationSchedulerLive,
                    richTextService: dependencies.richTextService
                )
            }
        }
    }
}

struct NoteDetailContentView: View {
    @Bindable var viewModel: NoteDetailViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    private var editorWidth: CGFloat {
        (UIScreen.current?.bounds.width ?? 390) - 32
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Başlık", text: $viewModel.title)
                .font(.largeTitle)
                .bold()
                .textFieldStyle(.plain)
                .submitLabel(.done)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    RichTextEditor(
                        attributedText: $viewModel.attributedText,
                        resetStyleTrigger: $viewModel.resetStyleTrigger,
                        selectedRange: $viewModel.selectedRange,
                        isFocused: $viewModel.isFocused,
                        formatState: $viewModel.formatState,
                        placeholder: ""
                    )
                    .padding(.horizontal)
                }
                
                if viewModel.isFocused {
                    RichTextAccessoryBar(
                        formatState: $viewModel.formatState,
                        onImageLoaded: { image in
                            Task { await viewModel.insertImage(image, editorWidth: editorWidth) }
                        },
                        onCameraTapped: {
                            viewModel.isCameraPresented = true
                        },
                        editorWidth: editorWidth
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraPicker { image in
                Task {
                    await viewModel.insertImage(image, editorWidth: editorWidth)
                }
            }
            .ignoresSafeArea()
        }
        .overlay {
            if viewModel.isReminderAlertPresented {
                ReminderAlertView(
                    isPresented: $viewModel.isReminderAlertPresented,
                    selectedDate: $viewModel.selectedReminderDate,
                    onSave: {
                        viewModel.saveReminder()
                    }
                )
                .ignoresSafeArea()
            }
        }
        .navigationTitle("")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Reminder") {
                        withAnimation {
                            viewModel.isReminderAlertPresented = true
                        }
                    }
                    
                    Button("Move to") {
                        router.push(.moveToFolder(viewModel.note))
                    }
                    
                    Button("Delete") {
                        if viewModel.delete() {
                            router.pop()
                        }
                    }
                    
                } label : {
                    Label("Options", systemImage: "ellipsis")
                }
            }
        }
        .task(id: editorWidth) {
            guard editorWidth > 0 else { return }
            await viewModel.resizeAttachmentsIfNeeded(maxWidth: editorWidth)
        }
        .onDisappear() {
            viewModel.onDisappear()
        }
        .alert("Bir hata oluştu", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .background(Color.appPageBackground)
    }
}
