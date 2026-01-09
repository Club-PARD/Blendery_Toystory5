import SwiftUI

struct RootView: View {

    // ===============================
    //  뷰 상태 변수
    // ===============================
    @State private var isLoggedIn = false
    @State private var appResetID = UUID()

    // ===============================
    //  환경 오브젝트 (BlenderyApp에서 주입받음)
    // ===============================
    @EnvironmentObject var favoriteStore: FavoriteStore

    var body: some View {
        NavigationStack {
            Group {
                if isLoggedIn {
                    Mainpage_View(
                        onLogout: { logout() }
                    )
                } else {
                    OnboardingAnimationView(
                        onLoginSuccess: { isLoggedIn = true }
                    )
                }
            }
        }
        .id(appResetID)
        .onAppear { checkAutoLogin() }
    }

    // ===============================
    //  자동 로그인 체크
    // ===============================
    private func checkAutoLogin() {
        guard
            let userId = SessionManager.shared.currentUserId,
            KeychainHelper.shared.readToken(for: userId) != nil
        else { return }

        isLoggedIn = true
    }

    // ===============================
    //  로그아웃
    // ===============================
    private func logout() {
        if let userId = SessionManager.shared.currentUserId {
            KeychainHelper.shared.deleteToken(for: userId)
        }

        SessionManager.shared.currentUserId = nil
        isLoggedIn = false

        // ✅ (선택) 로그아웃 시 즐겨찾기 로컬 캐시 초기화/시드
        // favoriteStore.resetToSeed()  // 너가 원하면 여기서 호출

        appResetID = UUID()
    }
}
