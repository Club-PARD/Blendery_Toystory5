//
//  OptionButton.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct OptionButton: View {
    
    // 아이스 메뉴 토글 조정 코드로 수정하였음
    @Binding var temperature: Temperature
    @Binding var size: Size

    let showTemperatureToggle: Bool
    let showSizeToggle: Bool

    var body: some View {
        VStack(spacing: 16) {

            if showTemperatureToggle {
                TemperatureSegment(selected: $temperature)
            }

            if showSizeToggle {
                SizeSegment(selected: $size)
            }
        }
        .padding(16)              // ✅ 그대로 유지 (토글 위치/간격 그대로)
                .frame(width: 176.34)
    }
}
