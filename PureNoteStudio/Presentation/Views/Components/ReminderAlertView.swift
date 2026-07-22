//
//  ReminderAlertView.swift
//  PureNoteStudio
//
//  Created by Semih TAKILAN on 22.07.2026.
//


import SwiftUI

struct ReminderAlertView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    var onSave: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 20) {
                Text("Hatırlatıcı Kur")
                    .font(.headline)
                    .padding(.top, 8)

                DatePicker(
                    "Tarih ve Saat",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                HStack(spacing: 16) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("İptal")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        onSave()
                        isPresented = false
                    } label: {
                        Text("Kaydet")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}
