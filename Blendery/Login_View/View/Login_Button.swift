//
//  Login_Button.swift
//  Blendery
//
//  Created by 박성준 on 12/25/25.
//

import SwiftUI

struct Login_Button: View {

    // [상태/뷰모델 변수]
    // - 내부에 email/password 서버 요청 데이터, isLoading/isLoggedIn/errorMessage UI 상태 등을 들고 있음
    // - 여기서는 주로 isLoading 같은 "UI 상태"를 읽어서 버튼/스피너에 반영
    @StateObject private var viewModel = LoginViewModel()

    // 상태 변수 화면 전환용
    // - NavigationLink를 트리거하기 위한 로컬 UI 상태
    @State private var goMain: Bool = false

    var body: some View {
        ZStack {
            Button(action: {
                goMain = true
            }) {

                // UI 상태 반영
                // - viewModel.isLoading 값에 따라 스피너/텍스트를 바꿈
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                } else {
                    Text("로그인")
                        .fontWeight(.semibold)
                }
            }
            .frame(width: 300, height: 45)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(30)

            // UI 상태 반영
            // - 로딩 중이면 버튼 비활성화
            .disabled(viewModel.isLoading)

            // 상태 기반 네비게이션
            // - goMain이 true가 되면 Mainpage_View로 이동
            NavigationLink(
                destination: Mainpage_View(),
                isActive: $goMain
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
}

#Preview {
    Login_Button()
}
