import SwiftUI

struct PillSegment: View {

    // [입력 변수]
    let title: String
    let isSelected: Bool
    let action: () -> Void

    // [입력 변수]
    // - 슬라이드 애니메이션용
    let namespace: Namespace.ID
    let indicatorID: String

    // [UI 상수]
    private let pillWidth: CGFloat = 76.675

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isSelected
                                 ? .white
                                 : Color(red: 114/255, green: 114/255, blue: 114/255, opacity: 1))

                // ✅ 기존 너가 쓰던 폭/레이아웃 그대로 유지
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .frame(width: pillWidth)

                // ✅ 선택 캡슐: 위아래는 맞고, 양옆만 더 키우기 + 슬라이드
                .background(alignment: .center) {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 60/255, green: 60/255, blue: 60/255, opacity: 1))
                            .matchedGeometryEffect(id: indicatorID, in: namespace)

                            // ⭐️ 여기 핵심: 세로는 살짝만, 가로는 더 많이 확장
                            .padding(.vertical, -1)
                            .padding(.horizontal, -4) // ← 양옆 남는거 줄이려면 -4 ~ -6 사이로 조절
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
