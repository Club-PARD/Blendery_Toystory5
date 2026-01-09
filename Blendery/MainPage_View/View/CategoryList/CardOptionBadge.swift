import SwiftUI

struct CardOptionBadge: View {
    let tags: [String]   // 예: ["ICE", "EX"] 또는 ["HOT", "L", "NEW"]

    var body: some View {
        if tags.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: 0) {

                // ✅ 최대 3개까지만 표시, 실제 개수에 맞게 divider 처리
                let showTags = Array(tags.prefix(3))

                ForEach(Array(showTags.enumerated()), id: \.offset) { idx, t in
                    optionText(t)
                        .padding(.horizontal, 8)

                    if idx != showTags.count - 1 {
                        verticalDivider()
                    }
                }
            }
            .frame(height: 28.7)
            .fixedSize(horizontal: true, vertical: false)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 255/255, green: 230/255, blue: 230/255).opacity(0.2))
            )
        }
    }

    // ===============================
    //  내부 컴포넌트
    // ===============================
    private func optionText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(red: 226/255, green: 49/255, blue: 0/255))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }

    private func verticalDivider() -> some View {
        Rectangle()
            .fill(Color(red: 218/255, green: 218/255, blue: 218/255))
            .frame(width: 1, height: 20)
            .scaleEffect(x: 0.3, y: 1, anchor: .center)
    }
}

//#Preview {
//    VStack(spacing: 12) {
//        CardOptionBadge(tags: ["ICE", "EX"])
//        CardOptionBadge(tags: ["HOT", "L"])
//        CardOptionBadge(tags: [])
//    }
//    .padding()
//    .background(Color.gray.opacity(0.1))
//}
