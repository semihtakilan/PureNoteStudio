//
//  RichTextEditor.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 7.07.2026.
//

import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var resetStyleTrigger: Bool
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    var placeholder: String = ""
    
    @AppStorage("appFontSize") private var appFontSize: AppFontSize = .medium
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        textView.font = UIFont.systemFont(ofSize: appFontSize.uiFontPoint)
        
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
        
        if uiView.font?.pointSize != appFontSize.uiFontPoint {
            uiView.font = UIFont.systemFont(ofSize: appFontSize.uiFontPoint)
        }
        
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
        
        if resetStyleTrigger {
            let resetFont = UIFont.systemFont(ofSize: appFontSize.uiFontPoint)
            
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            attributedText: $attributedText,
            selectedRange: $selectedRange,
            isFocused: $isFocused,
            placeholder: placeholder,
            appFontSize: appFontSize
        )
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var attributedText: NSAttributedString
        @Binding var selectedRange: NSRange
        @Binding var isFocused: Bool
        let placeholder: String
        var appFontSize: AppFontSize
        weak var textView: UITextView?
        
        var isEditing: Bool = false
        
        init(attributedText: Binding<NSAttributedString>, selectedRange: Binding<NSRange>, isFocused: Binding<Bool>, placeholder: String, appFontSize: AppFontSize) {
            self._attributedText = attributedText
            self._selectedRange = selectedRange
            self._isFocused = isFocused
            self.placeholder = placeholder
            self.appFontSize = appFontSize
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.isEditing = true
            Task { @MainActor in self.isFocused = true }
            
            if textView.text == placeholder {
                textView.text = ""
                textView.textColor = .label
                textView.font = UIFont.systemFont(ofSize: appFontSize.uiFontPoint)
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
        }
    }
}
