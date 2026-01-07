import Foundation
import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAutoLogin: Bool = false

    private let authService = AuthService()

    func login() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "이메일/비밀번호를 입력해주세요."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let req = LoginRequest(
                    email: trimmedEmail,
                    password: trimmedPassword
                )

                // ✅ res 자체가 accessToken(String)
                let accessToken = try await authService.login(request: req)

                TokenStore.saveAccessToken(accessToken)
                isLoggedIn = true

            } catch {
                isLoggedIn = false
                errorMessage = "로그인 실패: \(error.localizedDescription)"
                print("❌ login error:", error)
            }
        }
    }
}

