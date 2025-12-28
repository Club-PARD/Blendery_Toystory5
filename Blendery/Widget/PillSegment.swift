//
//  SwiftUIView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct PillSegment: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(.darkGray) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PillSegment(
        title: "hot",
        isSelected: true,
        action: {
            print("HOT tapped")
        }
    )
}
