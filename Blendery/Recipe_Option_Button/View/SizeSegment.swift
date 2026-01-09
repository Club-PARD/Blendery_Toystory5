import SwiftUI

struct SizeSegment: View {
    @Binding var selected: Size

    // ✅ 슬라이드 애니메이션용
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {

            PillSegment(
                title: "L",
                isSelected: selected == .large,
                action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selected = .large
                    }
                },
                namespace: ns,
                indicatorID: "sizeIndicator"
            )

            PillSegment(
                title: "XL",
                isSelected: selected == .extra,
                action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selected = .extra
                    }
                },
                namespace: ns,
                indicatorID: "sizeIndicator"
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
