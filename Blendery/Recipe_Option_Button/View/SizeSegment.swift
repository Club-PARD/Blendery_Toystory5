//
//  SizeSegment.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct SizeSegment: View {
    @Binding var selected: Size

    var body: some View {
        HStack(spacing: 4) {
            PillSegment(
                title: "L",
                isSelected: selected == .large
            ) {
                selected = .large
            }

            PillSegment(
                title: "XL",
                isSelected: selected == .extra
            ) {
                selected = .extra
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white)
                .frame(height: 38.852)
        )
    }
}
