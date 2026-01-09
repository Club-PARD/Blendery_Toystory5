//
//  TemparatureSegment.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct TemperatureSegment: View {
    @Binding var selected: Temperature

    // ✅ 슬라이드 애니메이션용
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {

            PillSegment(
                title: "HOT",
                isSelected: selected == .hot,
                action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selected = .hot
                    }
                },
                namespace: ns,
                indicatorID: "tempIndicator"
            )

            PillSegment(
                title: "ICE",
                isSelected: selected == .ice,
                action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selected = .ice
                    }
                },
                namespace: ns,
                indicatorID: "tempIndicator"
            )
        }
        .padding(4)

        // ✅ 알약 테두리(연한 회색) + 크기 그대로
        .background(
            Capsule()
                .fill(Color.white)
                .frame(height: 38.852)
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.86, green: 0.86, blue: 0.86), lineWidth: 1)
                .frame(height: 38.852)
        )
    }
}
