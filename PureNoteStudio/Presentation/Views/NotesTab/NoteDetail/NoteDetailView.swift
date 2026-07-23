//
//  NoteDetailView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 30.06.2026.
//

import SwiftUI

struct NoteDetailView: View {
    @State private var viewModel: NoteDetailViewModel
    
    @Environment(NotesRouter.self)
    private var router
    
    private var editorWidth: CGFloat {
        (UIScreen.current?.bounds.width ?? 390) - 32
    }
    
    init(
        note: Note,
        noteRepository: NoteRepository,
        categoryRepository: CategoryRepository,
        notificationManager: NotificationManager,
        richTextService: RichTextServiceProtocol
    ) {
        self._viewModel = State(
            initialValue: NoteDetailViewModel(
                note: note,
                noteRepository: noteRepository,
                categoryRepository: categoryRepository,
                notificationManager: notificationManager,
                richTextService: richTextService
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.title)
                .font(.largeTitle)
                .bold()
            
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RichTextEditor(
                    attributedText: $viewModel.attributedText,
                    placeholder: "",
                    resetStyleTrigger: $viewModel.resetStyleTrigger,
                    selectedRange: $viewModel.selectedRange,
                    isFocused: $viewModel.isFocused
                )
                .padding(.horizontal)
            }
            
            if viewModel.isFocused {
                HStack {
                    AttachmentMenu(
                        onImageLoaded: { image in
                            Task {
                                await viewModel.insertImage(image, editorWidth: editorWidth)
                            }
                        },
                        onCameraTapped: {
                            print("Kamera özelliği yakında eklenecek!")
                        }
                    )
                    
                    Spacer()
                    
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemGray6))
            }
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
                        viewModel.delete()
                        router.pop()
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
    }
}

