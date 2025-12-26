//
//  LogoAnimationView.swift
//  Blendery
//
//  Created by 박성준 on 12/26/25.
//

import SwiftUI

struct OnboardingAnimationView: View {
    @State private var didSetup = false

    // ✅ "처음 한 번" 측정한 화면값(이후 키보드 떠도 안 바뀜)
    @State private var baseSize: CGSize = .zero
    @State private var baseInsets: EdgeInsets = .init()

    @State private var logoY: CGFloat = 0
    @State private var showLoginUI = false

    private let logoSize: CGFloat = 120
    private let gapToField: CGFloat = 120

    var body: some View {
        GeometryReader { geo in
            // ✅ 처음 측정값이 있으면 그걸 쓰고, 없으면 현재 geo를 임시로 사용
            let width  = (baseSize == .zero) ? geo.size.width  : baseSize.width
            let height = (baseSize == .zero) ? geo.size.height : baseSize.height
            let insets = (baseSize == .zero) ? geo.safeAreaInsets : baseInsets

            // ✅ "보이는 화면(안전영역) 기준" 정중앙
            let safeCenterY = (height - insets.top - insets.bottom) / 2 + insets.top

            // 로그인 블록 위치(안전영역 기준으로 배치)
            let loginBlockY = (height - insets.top - insets.bottom) * 0.45 + insets.top
            let logoTargetY = loginBlockY - gapToField - (logoSize / 2)

            ZStack {
                Color.black.ignoresSafeArea()

                // 로그인 UI (로고 이동 후 등장)
                LoginView()
                    .frame(width: width) // ✅ 폭 고정(레이아웃 깨짐 방지)
                    .position(x: width / 2, y: loginBlockY)
                    .opacity(showLoginUI ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: showLoginUI)
                    .allowsHitTesting(showLoginUI)

                // 로고 1개
                Image("로고")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .position(x: width / 2, y: logoY)
            }
            // ✅ 키보드가 떠도 SwiftUI가 레이아웃을 밀어올리지 않게
            .ignoresSafeArea(.keyboard, edges: .all)
            .onAppear {
                guard !didSetup else { return }
                didSetup = true

                // ✅ "처음 한 번"만 실제 컨테이너 크기/안전영역 저장
                baseSize = geo.size
                baseInsets = geo.safeAreaInsets

                // 시작: 안전영역 기준 정중앙
                logoY = safeCenterY

                // 중앙 → 위로 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        logoY = logoTargetY
                    }
                }

                // 이동 끝난 뒤 로그인 UI 등장
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showLoginUI = true
                }
            }
        }
    }
}

struct OnboardingAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingAnimationView()
    }
}
