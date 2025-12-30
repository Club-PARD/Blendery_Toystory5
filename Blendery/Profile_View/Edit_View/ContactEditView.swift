//
//  ContactEditView.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import SwiftUI

struct ContactEditView: View {

    let type: ContactEditType

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {

            VStack(alignment: .leading, spacing: 8) {
                Text(type.placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                TextField(type.placeholder, text: $text)
                    .keyboardType(type.keyboard)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
            }
            .padding(.top, 20)

            Button("완료") {
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle(ContactEditType.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactEditView(type: .phone)
    }
}
