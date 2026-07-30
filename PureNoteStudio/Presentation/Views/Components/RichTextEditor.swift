//
//  RichTextEditor.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 7.07.2026.
//

import SwiftUI
import UIKit

struct RichTextFormatState: Equatable {
    var isBold: Bool = false
    var isItalic: Bool = false
    var fontSize: CGFloat = 17
}

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var resetStyleTrigger: Bool
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    @Binding var formatState: RichTextFormatState
    
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        
        context.coordinator.textView = textView
        
        if attributedText.string.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        } else {
            textView.attributedText = attributedText
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let isCurrentlyPlaceholder = uiView.text == placeholder
        
        // 🚀 BİÇİMLENDİRME: Dışarıdan butona basıldığında stili uygula
        if context.coordinator.lastKnownFormatState != formatState && !isCurrentlyPlaceholder {
            applyFormatting(to: uiView, state: formatState)
            context.coordinator.lastKnownFormatState = formatState
            
            // Metin seçiliyken format uygulandıysa AttributedText değişmiştir, ViewModel'a bildir
            if uiView.selectedRange.length > 0 {
                Task { @MainActor in
                    self.attributedText = uiView.attributedText
                }
            }
        }
        
        // Placeholder Kontrolleri
        if attributedText.string.isEmpty {
            if !context.coordinator.isEditing && !isCurrentlyPlaceholder {
                uiView.text = placeholder
                uiView.textColor = .placeholderText
            }
        } else {
            if isCurrentlyPlaceholder {
                uiView.text = ""
                uiView.textColor = .label
            }
            
            if uiView.attributedText !== attributedText, uiView.attributedText != attributedText {
                let preservedRange = uiView.selectedRange
                uiView.attributedText = attributedText
                
                if preservedRange.location <= attributedText.length {
                    uiView.selectedRange = preservedRange
                } else {
                    uiView.selectedRange = NSRange(location: attributedText.length, length: 0)
                }
            }
        }
        
        // Resim vb. eklenince stili sıfırlama tetikleyicisi
        if resetStyleTrigger {
            var traits: UIFontDescriptor.SymbolicTraits = []
            if formatState.isBold { traits.insert(.traitBold) }
            if formatState.isItalic { traits.insert(.traitItalic) }
            
            let descriptor = UIFont.systemFont(ofSize: formatState.fontSize).fontDescriptor
            let fontDescriptor = descriptor.withSymbolicTraits(traits) ?? descriptor
            let resetFont = UIFont(descriptor: fontDescriptor, size: formatState.fontSize)
            
            let newAttributes: [NSAttributedString.Key: Any] = [
                .font: resetFont,
                .foregroundColor: UIColor.label
            ]
            
            uiView.typingAttributes = newAttributes
            uiView.selectedRange = NSRange(location: uiView.attributedText.length, length: 0)
            
            let triggerBinding = $resetStyleTrigger
            Task { @MainActor in
                triggerBinding.wrappedValue = false
            }
        }
    }
    
    // 🚀 YARDIMCI FONKSİYON: Yazıyı şekillendiren asıl mekanizma
    private func applyFormatting(to textView: UITextView, state: RichTextFormatState) {
        var traits: UIFontDescriptor.SymbolicTraits = []
        if state.isBold { traits.insert(.traitBold) }
        if state.isItalic { traits.insert(.traitItalic) }
        
        let descriptor = UIFont.systemFont(ofSize: state.fontSize).fontDescriptor
        let fontDescriptor = descriptor.withSymbolicTraits(traits) ?? descriptor
        let updatedFont = UIFont(descriptor: fontDescriptor, size: state.fontSize)
        
        // 1. Durum: Metin seçiliyse (Highlight), seçili yeri formatla
        if textView.selectedRange.length > 0 {
            let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableAttrString.addAttribute(.font, value: updatedFont, range: textView.selectedRange)
            textView.attributedText = mutableAttrString
        }
        
        // 2. Durum: Yeni yazılacak karakterler için klavye hafızasını (Typing Attributes) güncelle
        var typingAttributes = textView.typingAttributes
        typingAttributes[.font] = updatedFont
        typingAttributes[.foregroundColor] = UIColor.label
        textView.typingAttributes = typingAttributes
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            attributedText: $attributedText,
            selectedRange: $selectedRange,
            isFocused: $isFocused,
            formatState: $formatState,
            placeholder: placeholder
        )
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var attributedText: NSAttributedString
        @Binding var selectedRange: NSRange
        @Binding var isFocused: Bool
        @Binding var formatState: RichTextFormatState
        
        let placeholder: String
        weak var textView: UITextView?
        
        var isEditing: Bool = false
        var lastKnownFormatState = RichTextFormatState()
        
        init(attributedText: Binding<NSAttributedString>, selectedRange: Binding<NSRange>, isFocused: Binding<Bool>, formatState: Binding<RichTextFormatState>, placeholder: String) {
            self._attributedText = attributedText
            self._selectedRange = selectedRange
            self._isFocused = isFocused
            self._formatState = formatState
            self.placeholder = placeholder
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.isEditing = true
            Task { @MainActor in self.isFocused = true }
            
            if textView.text == placeholder {
                textView.text = ""
                textView.textColor = .label
                
                // Placeholder silindiğinde formatState'e uygun fontla yazmaya başla
                var traits: UIFontDescriptor.SymbolicTraits = []
                if formatState.isBold { traits.insert(.traitBold) }
                if formatState.isItalic { traits.insert(.traitItalic) }
                let descriptor = UIFont.systemFont(ofSize: formatState.fontSize).fontDescriptor
                let fontDescriptor = descriptor.withSymbolicTraits(traits) ?? descriptor
                
                let font = UIFont(descriptor: fontDescriptor, size: formatState.fontSize)
                textView.typingAttributes[.font] = font
                textView.typingAttributes[.foregroundColor] = UIColor.label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            self.isEditing = false
            Task { @MainActor in self.isFocused = false }
            
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textColor = .placeholderText
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.text == placeholder {
                attributedText = NSAttributedString(string: "")
            } else {
                Task { @MainActor in
                    self.attributedText = textView.attributedText
                }
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard textView.text != placeholder else { return }
            
            Task { @MainActor in
                self.selectedRange = textView.selectedRange
            }
            
            // 🚀 İMLEÇ KONTROLÜ: Kullanıcı farklı bir kelimeye tıkladığında o kelimenin font ayarını UI'a yansıt
            if let typingFont = textView.typingAttributes[.font] as? UIFont {
                let isBold = typingFont.fontDescriptor.symbolicTraits.contains(.traitBold)
                let isItalic = typingFont.fontDescriptor.symbolicTraits.contains(.traitItalic)
                let newFormat = RichTextFormatState(isBold: isBold, isItalic: isItalic, fontSize: typingFont.pointSize)
                
                if self.lastKnownFormatState != newFormat {
                    Task { @MainActor in
                        self.formatState = newFormat
                        self.lastKnownFormatState = newFormat
                    }
                }
            }
        }
    }
}
