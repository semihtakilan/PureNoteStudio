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
    
    @State private var isFormattingExpanded: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            
            if isFormattingExpanded {
                // MARK: - GENİŞLETİLMİŞ FORMAT MENÜSÜ
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFormattingExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 20)
                
                Button {
                    formatState.isBold.toggle()
                } label: {
                    Image(systemName: "bold")
                        .font(.system(size: 18, weight: formatState.isBold ? .black : .regular))
                        .foregroundColor(formatState.isBold ? .accentColor : .primary)
                }
                
                Button {
                    formatState.isItalic.toggle()
                } label: {
                    Image(systemName: "italic")
                        .font(.system(size: 18, weight: formatState.isItalic ? .black : .regular))
                        .foregroundColor(formatState.isItalic ? .accentColor : .primary)
                }
                
                Divider()
                    .frame(height: 20)
                
                HStack(spacing: 12) {
                    Button {
                        if formatState.fontSize > 12 { formatState.fontSize -= 2 }
                    } label: {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(Int(formatState.fontSize))")
                        .font(.subheadline)
                        .monospacedDigit()
                        .frame(width: 24)
                    
                    Button {
                        if formatState.fontSize < 36 { formatState.fontSize += 2 }
                    } label: {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(.primary)
                    }
                }
                
            } else {
                // MARK: - STANDART GÖRÜNÜM
                AttachmentMenu(
                    onImageLoaded: onImageLoaded,
                    onCameraTapped: onCameraTapped
                )
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFormattingExpanded = true
                    }
                } label: {
                    Image(systemName: "textformat.alt")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // MARK: - Klavyeyi Kapatma Butonu
            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
    }
}
