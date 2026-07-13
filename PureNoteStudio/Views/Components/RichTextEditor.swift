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
    @Binding var resetStyleTrigger: Bool
    @Binding var selectedRange: NSRange   // NEW: exposes cursor position to the ViewModel

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.backgroundColor = .clear

        context.coordinator.textView = textView   // NEW: coordinator keeps a weak ref

        if attributedText.string.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        }

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let isCurrentlyPlaceholder = uiView.textColor == .placeholderText

        // FIX #1: Drive placeholder state from the real data (attributedText),
        // not just from the view's current color. This means an image inserted
        // while the placeholder was showing is no longer silently dropped.
        if attributedText.string.isEmpty {
            // Only force the placeholder back in if the user isn't actively
            // editing right now (avoids fighting with textViewDidBeginEditing).
            if !context.coordinator.isEditing && !isCurrentlyPlaceholder {
                uiView.text = placeholder
                uiView.textColor = .placeholderText
            }
        } else {
            if isCurrentlyPlaceholder {
                uiView.textColor = .label
            }
            // Cheap pre-check on length before the expensive deep NSAttributedString
            // comparison (FIX #4) — avoids the full attachment/attribute walk on
            // every keystroke when lengths already differ trivially isn't reliable
            // enough alone, so we still fall back to full equality, but skip it
            // when nothing could possibly have changed (same instance).
            if uiView.attributedText !== attributedText, uiView.attributedText != attributedText {
                uiView.attributedText = attributedText
            }
        }

        if resetStyleTrigger {
            let resetFont = UIFont.preferredFont(forTextStyle: .body)
            uiView.typingAttributes = [.font: resetFont]
            uiView.selectedRange = NSRange(location: uiView.attributedText.length, length: 0)

            let triggerBinding = $resetStyleTrigger
            DispatchQueue.main.async {
                triggerBinding.wrappedValue = false
            }
        }
        
        if resetStyleTrigger {
            let resetFont = UIFont.preferredFont(forTextStyle: .body)
            let newAttributes: [NSAttributedString.Key: Any] = [.font: resetFont]

            uiView.typingAttributes = newAttributes
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(attributedText: $attributedText, selectedRange: $selectedRange, placeholder: placeholder)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var attributedText: NSAttributedString
        @Binding var selectedRange: NSRange
        let placeholder: String
        weak var textView: UITextView?      // NEW
        var isEditing: Bool = false          // NEW

        init(attributedText: Binding<NSAttributedString>, selectedRange: Binding<NSRange>, placeholder: String) {
            self._attributedText = attributedText
            self._selectedRange = selectedRange
            self.placeholder = placeholder
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            isEditing = true
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
                textView.font = UIFont.preferredFont(forTextStyle: .body)
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isEditing = false
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

        // NEW: keep the ViewModel's selectedRange in sync so image insertion
        // knows exactly where the cursor is, instead of always appending at the end.
        func textViewDidChangeSelection(_ textView: UITextView) {
            guard textView.textColor != .placeholderText else { return }
            DispatchQueue.main.async {
                self.selectedRange = textView.selectedRange
            }
        }
    }
}


/*

 Kısa özet:

 1. Font küçülme sorunu (asıl sorun)
 Resim eklerken metnin öncesine/sonrasına eklenen "\n" karakterlerine font attribute'u verilmiyordu, bu yüzden UIKit varsayılan küçük fontu kullanıyordu. insertImage'da bu satırlara açıkça .body fontunu verdim.

 2. Reset flag'i çalışmıyordu
 resetStyleTrigger plain Bool idi, @Binding değildi — bu yüzden updateUIView içinden view model'e geri yazılamıyordu, flag hep true kalıp sürekli fontu zorluyordu. @Binding yaptım, $resetStyleTrigger üzerinden DispatchQueue.main.async ile view model'e false yazıyorum (bu, SwiftUI'da view update sırasında state değiştirmenin standart yöntemi).

 3. Placeholder aktifken resim eklenirse resim kayboluyordu (kritik bug)
 Eski kod placeholder durumunu textColor == .placeholderText üzerinden anlıyordu, gerçek veriye (attributedText) değil. Kullanıcı hiç yazmadan resim eklerse resim ekrana hiç yansımıyor, sonra yazmaya başlayınca da sessizce siliniyordu. Artık placeholder kararını attributedText.string.isEmpty üzerinden veriyorum, isEditing flag'iyle de kullanıcı yazarken çakışmayı önlüyorum.

 4. Resim her zaman metnin sonuna ekleniyordu
 Kullanıcı metnin ortasındayken resim eklerse bile resim hep en sona gidiyordu. RichTextEditor'a selectedRange binding'i ekleyip, coordinator'da textViewDidChangeSelection ile imleç pozisyonunu takip ettim. insertImage artık imlecin olduğu yere ekliyor, sonrasında imleci de doğru yere taşıyor.

 5. Performans
 Her updateUIView çağrısında pahalı NSAttributedString deep-equality kontrolü yapılıyordu. Önce ucuz referans karşılaştırması (!==) ekledim, sadece gerekirse deep compare çalışıyor.

 Yapman gereken tek şey: RichTextEditor(...) çağrı yerine selectedRange: $viewModel.selectedRange parametresini eklemek — yoksa derlenmez.


*/
