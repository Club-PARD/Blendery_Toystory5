//
//  RootView.swift
//  Blendery
//
//  Created by 박영언 on 1/8/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var isLoggedIn = false
    @State private var loginViewID = UUID()
    @State private var mainViewID = UUID()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    Mainpage_View(
                        onLogout: {
                            logout()
                        }
                    )
                    .id(mainViewID)
                } else {
                    OnboardingAnimationView(
                        onLoginSuccess: {
                            isLoggedIn = true
                            mainViewID = UUID()
                        }
                    )
                    .id(loginViewID)
                }
            }
        }
        .onAppear {
            checkAutoLogin()
        }
    }
    
    private func checkAutoLogin() {
        guard
            let userId = SessionManager.shared.currentUserId,
            let _ = KeychainHelper.shared.readToken(for: userId)
        else {
            print("자동 로그인 실패")
            return
        }
        
        print("✅ 자동 로그인 성공")
        isLoggedIn = true
    }
    
    private func logout() {
        guard let userId = SessionManager.shared.currentUserId else { return }
        KeychainHelper.shared.deleteToken(for: userId)
        SessionManager.shared.currentUserId = nil
        
        mainViewID = UUID()
        print("MainView 리셋")
        loginViewID = UUID()
        print("LoginView 리셋")
        isLoggedIn = false
        print("로그아웃 완료")
    }
}
