import SwiftUI
import UIKit

// ✅ 파일 내부 전용으로 이름 바꿔서 충돌 방지
private struct FavoriteCardHeightKey: PreferenceKey {
    static var defaultValue: [UUID: CGFloat] = [:]
    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_FavoriteListView: View {

    @EnvironmentObject var favoriteStore: FavoriteStore
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    @State private var measuredHeights: [UUID: CGFloat] = [:]

    // 레이아웃 상수
    private let spacing: CGFloat = 17
    private let horizontalPadding: CGFloat = 17

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width - (horizontalPadding * 2) - spacing
            let columnWidth = max(0, availableWidth / 2)

            let columns = distributeMasonry(
                items: favoriteStore.cards,
                heights: measuredHeights,
                spacing: spacing,
                defaultHeight: 200
            )

            ScrollView {
                if favoriteStore.cards.isEmpty {
                    VStack(spacing: 12) {
                        Text("즐겨찾기한 레시피가 없습니다")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        Text("북마크를 눌러 레시피를 저장해보세요")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.top, 40)

                } else {
                    HStack(alignment: .top, spacing: spacing) {

                        VStack(spacing: spacing) {
                            ForEach(columns.left) { item in
                                favoriteCard(item)
                                    // ✅ 폭 고정 (줄바꿈/높이 결정 안정화)
                                    .frame(width: columnWidth)
                                    // ✅ 폭 고정된 최종 카드 높이를 측정
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.preference(
                                                key: FavoriteCardHeightKey.self,
                                                value: [item.id: proxy.size.height]
                                            )
                                        }
                                    )
                            }
                        }

                        VStack(spacing: spacing) {
                            ForEach(columns.right) { item in
                                favoriteCard(item)
                                    .frame(width: columnWidth)
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.preference(
                                                key: FavoriteCardHeightKey.self,
                                                value: [item.id: proxy.size.height]
                                            )
                                        }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 17)
                }
            }
            // ✅ 미세한 높이 흔들림 때문에 무한 재분배 방지
            .onPreferenceChange(FavoriteCardHeightKey.self) { new in
                updateMeasuredHeightsIfNeeded(new)
            }
        }
    }

    // MARK: - 카드 UI
    private func favoriteCard(_ item: MenuCardModel) -> some View {

        // ===============================
        //  콘텐츠 뷰: 높이는 내용대로만
        //  배경은 background로 감싸서 “내용 높이”만큼만 칠해지게
        // ===============================
        VStack(alignment: .leading, spacing: 5) {

            // 상단: 배지 + 북마크
            HStack(alignment: .top) {
                CardOptionBadge(tags: item.badgeTags)
                Spacer()

                CardFavoriteButton(isFavorite: true) {
                    favoriteStore.remove(recipeId: item.id)   // ✅ 즉시 삭제 + 토스트
                }
            }

            // 제목 / 설명
            Text(item.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            // 제조 단계
            VStack(alignment: .leading, spacing: 8) {
                ForEach(item.lines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 18))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 10)
        }
        .padding(20)

        // ===============================
        //  ✅ 배경: 콘텐츠 높이만큼만 칠해짐 (빈 공간 제거 핵심)
        // ===============================
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
        )

        // ===============================
        //  탭 영역: 카드 전체 터치 가능
        // ===============================
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            onSelectMenu(item)
        }
    }
    // MARK: - masonry 분배
    private func distributeMasonry(
        items: [MenuCardModel],
        heights: [UUID: CGFloat],
        spacing: CGFloat,
        defaultHeight: CGFloat
    ) -> (left: [MenuCardModel], right: [MenuCardModel]) {

        var left: [MenuCardModel] = []
        var right: [MenuCardModel] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in items {
            let h = heights[item.id] ?? defaultHeight
            if leftH <= rightH {
                left.append(item)
                leftH += h + spacing
            } else {
                right.append(item)
                rightH += h + spacing
            }
        }
        return (left, right)
    }

    // MARK: - measuredHeights 안정 업데이트
    private func updateMeasuredHeightsIfNeeded(_ new: [UUID: CGFloat]) {
        var updated = measuredHeights
        var changed = false

        // ✅ 이 값보다 작게 변하면 무시 (레이아웃 미세 흔들림 컷)
        let epsilon: CGFloat = 0.8

        for (id, h) in new {
            let old = updated[id] ?? 0
            if abs(old - h) > epsilon {
                updated[id] = h
                changed = true
            }
        }

        if changed {
            measuredHeights = updated
        }
    }
}
