//
//  RichTextAccessoryBar.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 29.07.2026.
//


import SwiftUI

struct RichTextAccessoryBar: View {
    @Binding var formatState: RichTextFormatState
    
    var onImageLoaded: (UIImage) -> Void
    var onCameraTapped: () -> Void
    var editorWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Ataş Menüsü
            AttachmentMenu(
                onImageLoaded: onImageLoaded,
                onCameraTapped: onCameraTapped
            )
            
            Divider()
                .frame(height: 20)
            
            // MARK: - Metin Biçimlendirme Araçları
            Button {
                formatState.isBold.toggle()
            } label: {
                Image(systemName: "bold")
                    .foregroundColor(formatState.isBold ? .accentColor : .primary)
            }
            
            Button {
                formatState.isItalic.toggle()
            } label: {
                Image(systemName: "italic")
                    .foregroundColor(formatState.isItalic ? .accentColor : .primary)
            }
            
            // Font Boyutu Artırma/Azaltma
            HStack(spacing: 8) {
                Button {
                    if formatState.fontSize > 12 { formatState.fontSize -= 2 }
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundColor(.primary)
                }
                
                Button {
                    if formatState.fontSize < 36 { formatState.fontSize += 2 }
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Klavyeyi Kapatma Butonu
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
