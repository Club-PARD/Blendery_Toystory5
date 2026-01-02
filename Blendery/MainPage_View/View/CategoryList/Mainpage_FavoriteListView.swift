//
//  Mainpage_FavoriteListView.swift
//  Blendery
//
//  즐겨찾기 리스트 뷰
//

import SwiftUI
import UIKit

private struct CardHeightKey: PreferenceKey {

    // UI 레이아웃 측정값 저장용
    static var defaultValue: [UUID: CGFloat] = [:]

    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {

        // UI 레이아웃 계산 로직
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_FavoriteListView: View {

    // 서버 연결 ?
    // 즐겨찾기 목록 조회, 즐겨찾기 토글 같은 로직을 vm이 담당할 가능성이 큼
    @ObservedObject var vm: MainpageViewModel

    // 화면 이동용
    // 메뉴 선택 시 상세 화면으로 넘기기 위한
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    // 카드 높이 측정값 저장
    @State private var measuredHeights: [UUID: CGFloat] = [:]

    var body: some View {

        // UI 배치 계산 결과
        let columns = vm.distributeMasonry(items: vm.favoriteItems, heights: measuredHeights)

        ScrollView {
            HStack(spacing: 17) {

                VStack(spacing: 17) {
                    ForEach(columns.left) { item in
                        MenuCardView(
                            model: item,

                            // 서버?
                            // 실제 서버 저장은 vm 내부 구현이 담당
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) },

                            // 화면 이동용 이벤트
                            onSelect: { onSelectMenu(item) }
                        )
                        .background(
                            GeometryReader { geo in
                                // UI 레이아웃 측정값 수집
                                Color.clear.preference(
                                    key: CardHeightKey.self,
                                    value: [item.id: geo.size.height]
                                )
                            }
                        )
                    }
                }

                VStack(spacing: 17) {
                    ForEach(columns.right) { item in
                        MenuCardView(
                            model: item,

                            // 서버 호출?
                            onToggleBookmark: { vm.toggleBookmark(id: item.id) },

                            // 화면 이동용 이벤트
                            onSelect: { onSelectMenu(item) }
                        )
                        .background(
                            GeometryReader { geo in
                                // UI 레이아웃 측정값 수집
                                Color.clear.preference(
                                    key: CardHeightKey.self,
                                    value: [item.id: geo.size.height]
                                )
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.top, 17)
        }

        // UI 상태 업데이트
        .onPreferenceChange(CardHeightKey.self) { new in
            if new != measuredHeights { measuredHeights = new }
        }
    }
}

// 즐겨찾기 카드 뷰
private struct MenuCardView: View {

    // 서버 데이터?
    // 메뉴 한 개의 표시 데이터
    let model: MenuCardModel

    // 서버 호출?
    // 즐겨찾기 토글 트리거
    let onToggleBookmark: () -> Void

    // 화면 이동용 이벤트
    let onSelect: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)

            // UI 터치 영역 처리
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {

                    // UI 태그 표시
                    ForEach(model.tags, id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.71, green: 0.71, blue: 0.71).opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Spacer()
                }

                Text(model.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text(model.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)

            Button(action: onToggleBookmark) {
                Image(model.isBookmarked ? "즐찾아이콘" : "즐찾끔")
                    .resizable()
                    .frame(width: 14, height: 17)
                    .padding(12)
            }
            .buttonStyle(.plain)
        }
    }
}
