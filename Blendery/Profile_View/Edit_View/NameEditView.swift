//
//  NameEditView.swift
//  Blendery
//
//  Created by 박영언 on 12/29/25.
//

import SwiftUI

struct NameEditView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    
    @FocusState private var isFocused: Bool

    init(viewModel: ProfileViewModel) {
            self.viewModel = viewModel
            _name = State(initialValue: "")
        }

    var body: some View {
        VStack(spacing: 16) {
            ProfileCard(
                viewModel: viewModel,
                showEditButton: false,
                showCameraButton: false,
                onTapEditName: nil,
                nameView: AnyView(
                    TextField(
                        viewModel.profile.name,
                        text: $name
                    )
                    .font(.system(size: 18, weight: .medium))
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 4)
                    .focused($isFocused)
                    
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.none)
                )
            )

            Button("완료") {
                if !name.isEmpty && name != viewModel.profile.name {
                    viewModel.updateName(name)
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("프로필 수정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            isFocused = true
        }
    }
}

#Preview {
    let mockProfile = UserProfile(
        name: "이지수",
        role: "매니저",
        joinedAt: "2010.12.25~",
        phone: "010-7335-1790",
        email: "l_oxo_l@handong.ac.kr"
    )

    let mockViewModel = ProfileViewModel(profile: mockProfile)

    NavigationStack {
        NameEditView(viewModel: mockViewModel)
    }
}
