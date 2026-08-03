//
//  RichTextEditor.swift
//  PureNoteStudio
//

import SwiftUI
import UIKit

struct RichTextFormatState: Equatable {
    var isBold = false
    var isItalic = false
    var fontSize: CGFloat = 17
}

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var resetStyleTrigger: Bool
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    @Binding var formatState: RichTextFormatState

    var placeholder = ""

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.showsVerticalScrollIndicator = false
        textView.adjustsFontForContentSizeCategory = true
        textView.keyboardDismissMode = .interactive
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 16, right: 4)
        textView.textContainer.lineFragmentPadding = 0
        textView.attributedText = attributedText
        textView.typingAttributes = typingAttributes(for: formatState, basedOn: nil)

        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.font = UIFont.preferredFont(forTextStyle: .body)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: textView.textContainerInset.left
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: textView.trailingAnchor,
                constant: -textView.textContainerInset.right
            ),
            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: textView.textContainerInset.top
            )
        ])

        context.coordinator.textView = textView
        context.coordinator.placeholderLabel = placeholderLabel
        context.coordinator.updatePlaceholderVisibility()
        context.coordinator.lastKnownFormatState = formatState
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        let coordinator = context.coordinator

        if !textView.attributedText.isEqual(to: attributedText) {
            coordinator.isSynchronizingView = true
            let range = clampedRange(selectedRange, textLength: attributedText.length)
            textView.attributedText = attributedText
            textView.selectedRange = range
            coordinator.isSynchronizingView = false
        }

        if coordinator.lastKnownFormatState != formatState {
            applyFormatting(to: textView, state: formatState)
            coordinator.lastKnownFormatState = formatState

            if textView.selectedRange.length > 0 {
                coordinator.publishTextChange()
            }
        }

        if resetStyleTrigger {
            textView.typingAttributes = typingAttributes(for: formatState, basedOn: textView.typingAttributes)
            textView.selectedRange = clampedRange(selectedRange, textLength: textView.attributedText.length)
            resetStyleTrigger = false
        }

        coordinator.updatePlaceholderVisibility()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            attributedText: $attributedText,
            selectedRange: $selectedRange,
            isFocused: $isFocused,
            formatState: $formatState
        )
    }

    private func applyFormatting(to textView: UITextView, state: RichTextFormatState) {
        let range = textView.selectedRange
        let currentFont = font(in: textView, at: range.location)
        let attributes = typingAttributes(for: state, basedOn: textView.typingAttributes, baseFont: currentFont)

        if range.length > 0 {
            let mutableText = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableText.addAttributes(attributes, range: range)
            textView.attributedText = mutableText
            textView.selectedRange = range
        }

        textView.typingAttributes.merge(attributes) { _, new in new }
    }

    private func typingAttributes(
        for state: RichTextFormatState,
        basedOn currentAttributes: [NSAttributedString.Key: Any]?,
        baseFont: UIFont? = nil
    ) -> [NSAttributedString.Key: Any] {
        var attributes = currentAttributes ?? [:]
        let font = font(with: state, basedOn: baseFont ?? attributes[.font] as? UIFont)
        attributes[.font] = font
        attributes[.foregroundColor] = UIColor.label
        return attributes
    }

    private func font(in textView: UITextView, at location: Int) -> UIFont? {
        guard textView.attributedText.length > 0 else { return nil }
        let index = min(max(location, 0), textView.attributedText.length - 1)
        return textView.attributedText.attribute(.font, at: index, effectiveRange: nil) as? UIFont
    }

    private func font(with state: RichTextFormatState, basedOn baseFont: UIFont?) -> UIFont {
        let source = baseFont ?? UIFont.preferredFont(forTextStyle: .body)
        var traits = source.fontDescriptor.symbolicTraits
        traits.remove([.traitBold, .traitItalic])
        if state.isBold { traits.insert(.traitBold) }
        if state.isItalic { traits.insert(.traitItalic) }

        let descriptor = source.fontDescriptor.withSymbolicTraits(traits) ?? source.fontDescriptor
        return UIFont(descriptor: descriptor, size: max(12, min(state.fontSize, 36)))
    }

    private func clampedRange(_ range: NSRange, textLength: Int) -> NSRange {
        let location = min(max(range.location, 0), textLength)
        return NSRange(location: location, length: min(max(range.length, 0), textLength - location))
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var attributedText: NSAttributedString
        @Binding var selectedRange: NSRange
        @Binding var isFocused: Bool
        @Binding var formatState: RichTextFormatState

        weak var textView: UITextView?
        weak var placeholderLabel: UILabel?
        var isSynchronizingView = false
        var lastKnownFormatState = RichTextFormatState()

        init(
            attributedText: Binding<NSAttributedString>,
            selectedRange: Binding<NSRange>,
            isFocused: Binding<Bool>,
            formatState: Binding<RichTextFormatState>
        ) {
            _attributedText = attributedText
            _selectedRange = selectedRange
            _isFocused = isFocused
            _formatState = formatState
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            isFocused = true
            updateFormatState(from: textView)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isFocused = false
        }

        func textViewDidChange(_ textView: UITextView) {
            guard !isSynchronizingView else { return }
            publishTextChange()
            updatePlaceholderVisibility()
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !isSynchronizingView else { return }
            selectedRange = textView.selectedRange
            updateFormatState(from: textView)
        }

        func publishTextChange() {
            guard let textView else { return }
            attributedText = textView.attributedText
        }

        func updatePlaceholderVisibility() {
            placeholderLabel?.isHidden = !(textView?.text.isEmpty ?? true)
        }

        private func updateFormatState(from textView: UITextView) {
            let font = selectedFont(in: textView) ?? UIFont.preferredFont(forTextStyle: .body)
            let traits = font.fontDescriptor.symbolicTraits
            let newState = RichTextFormatState(
                isBold: traits.contains(.traitBold),
                isItalic: traits.contains(.traitItalic),
                fontSize: font.pointSize
            )

            guard newState != lastKnownFormatState else { return }
            formatState = newState
            lastKnownFormatState = newState
        }

        private func selectedFont(in textView: UITextView) -> UIFont? {
            if let font = textView.typingAttributes[.font] as? UIFont {
                return font
            }
            guard textView.attributedText.length > 0 else { return nil }
            let index = min(textView.selectedRange.location, textView.attributedText.length - 1)
            return textView.attributedText.attribute(.font, at: index, effectiveRange: nil) as? UIFont
        }
    }
}
