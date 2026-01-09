//
//  OptionBadge.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct OptionBadge: View {
    let tags: [String]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tags.prefix(3).enumerated()), id: \.offset) { idx, t in
                optionText(t)
                    .padding(.horizontal, 8)

                if idx != min(tags.count, 3) - 1 {
                    verticalDivider()
                }
            }
        }
        .frame(height: 28.7)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 255/255, green: 230/255, blue: 230/255, opacity: 0.2))
        )
    }
}

private func optionText(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 12))
        .foregroundColor(Color(red: 226/255, green: 49/255, blue: 0/255, opacity: 1))
}

private func verticalDivider() -> some View {
    Rectangle()
        .fill(Color(red: 218/255, green: 218/255, blue: 218/255))
        .frame(width: 1, height: 20)
        .scaleEffect(x: 0.3, y: 1, anchor: .center)
}

//#Preview {
//    OptionBadge(
//        tags: ["ICE", "XL"]
//    )
//    .padding()
//    .previewLayout(.sizeThatFits)
//}

