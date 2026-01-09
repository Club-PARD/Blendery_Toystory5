//
//  BlenderyApp.swift
//  Blendery
//
//  Created by 박영언 on 12/24/25.
//

import SwiftUI

@main
struct BlenderyApp: App {

    @Environment(\.scenePhase) private var scenePhase

    // ✅ 상태 오브젝트 (전역 1개)
    @StateObject private var favoriteStore = FavoriteStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favoriteStore) // ✅ 여기서 "항상" 주입

                .onChange(of: scenePhase) { phase in
                    UIApplication.shared.isIdleTimerDisabled = (phase == .active)
                }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
    }
}
