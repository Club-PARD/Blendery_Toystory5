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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 247/255, green: 247/255, blue: 247/255, opacity: 1))
        )
        .frame(width: 176.34)
    }
}
