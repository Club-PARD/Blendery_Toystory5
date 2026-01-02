//
//  Mainpage_ScrollView.swift
//  Blendery
//
//  각 카테고리에 맞는 UI를 선택해서 보여주는 컨테이너
//

import SwiftUI

struct Mainpage_ScrollView: View {

    // 뷰 상태 전달용 입력
    let selectedCategory: String

    // 서버 연결 주체일 가능성 높음
    // 카테고리별 데이터 조회, 즐겨찾기 토글 로직이 여기로 들어갈 가능성 큼
    @ObservedObject var vm: MainpageViewModel

    // 화면 이동용 이벤트
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    var body: some View {

        // UI 분기 로직
        if selectedCategory == "즐겨찾기" {

            Mainpage_FavoriteListView(
                vm: vm,
                onSelectMenu: onSelectMenu
            )

        } else {

            // 서버 데이터일 가능성 높음
            // vm이 카테고리에 맞는 목록을 만들어서 준 데이터
            let items = vm.normalItems(for: selectedCategory)

            if selectedCategory == "시즌메뉴" {

                SeasonCarouselView(
                    items: items,
                    onSelectMenu: onSelectMenu,

                    // 서버?
                    onToggleBookmark: { vm.toggleBookmark(id: $0) }
                )

            } else {

                Mainpage_DefaultListView(
                    items: items,

                    // 서버? 즐찾토글
                    onToggleBookmark: { vm.toggleBookmark(id: $0) },

                    onSelectMenu: onSelectMenu
                )
            }
        }
    }
}
