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
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = .clear
        
        if attributedText.string.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        
        if uiView.textColor == .placeholderText {
            return
        }
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(attributedText: $attributedText, placeholder: placeholder)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var attributedText: NSAttributedString
        let placeholder: String
        
        init(attributedText: Binding<NSAttributedString>, placeholder: String) {
            self._attributedText = attributedText
            self.placeholder = placeholder
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
                textView.font = UIFont.preferredFont(forTextStyle: .body)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textColor = .placeholderText
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                attributedText = NSAttributedString(string: "")
            } else {
                attributedText = textView.attributedText
            }
        }
    }
}
