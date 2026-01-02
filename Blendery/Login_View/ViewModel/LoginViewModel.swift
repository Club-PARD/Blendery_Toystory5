//
//  LoginViewModel.swift
//  Blendery
//
//  Created by 박성준 on 12/24/25.
//

import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    
    //  서버 변수
    // - 로그인 요청(LoginRequest)
    @Published var email = ""
    @Published var password = ""

    //  상태 변수
    // - 로딩 스피너, 로그인 성공 후 화면 전환, 에러 토스트/텍스트 표시 등에 쓰임
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    // 서버 변수
        // AuthService 파일과 연결
    private let authService = AuthService()
    
    func login() {
            //  입력 검증 로직 (서버 호출 전에 막는 로직)
            guard !email.isEmpty, !password.isEmpty else { return }
            
            //  뷰 상태 변경 로딩 시작 + 에러 초기화
            isLoading = true
            errorMessage = nil
            
            //  비동기 처리(서버 통신 트리거)
            Task {
                //  뷰 상태 변경 작업 끝나면 로딩 종료 보장
                defer { isLoading = false }
                
                // 서버로 보낼 요청 데이터 생성
                let request = LoginRequest(email: email, password: password)
                
                do {
                    // 서버 통신 호출 지점
                    // - 여기서 authService가 서버에 요청 보내고 token을 받아오는 구조
                    let token = try await authService.login(request: request)
                    
                    // 서버 결과 처리 후 로컬 저장(토큰 저장)
                    // - 네트워크 자체는 아니지만 “로그인 이후 인증 유지” 관련 로직
                    saveToken(token)
                    
                    // 뷰 상태 변경 로그인 성공 상태
                    isLoggedIn = true
                    print("로그인 성공")
                    
                } catch {
                    //  [뷰(UI) 상태 변경] 에러 메시지 저장 (화면에 표시/토스트에 사용 가능)
                    print("에러 발생: \(error)")
                    errorMessage = "로그인 실패: \(error.localizedDescription)"
                }
            }
        }
    
    private func saveToken(_ token: String) {
        KeychainHelper.shared.saveToken(token: token)
    }
}
