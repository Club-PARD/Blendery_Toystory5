import SwiftUI

struct Mainpage_ScrollView: View {

    // 뷰 상태 전달용 입력
    let selectedCategory: String

    // 서버 메뉴 목록 데이터 소스
    @ObservedObject var vm: MainpageViewModel

    // 화면 이동용 이벤트
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    var body: some View {

        // ✅ 즐겨찾기 탭
        if selectedCategory == "즐겨찾기" {

            Mainpage_FavoriteListView(
                onSelectMenu: onSelectMenu
            )

        } else if selectedCategory == "시즌메뉴" {

            // ✅ 시즌메뉴 탭 (API 없이 allCards에서 6개 필터링)
            if vm.seasonItems.isEmpty {
                VStack(spacing: 10) {
                    Text("시즌 메뉴가 없습니다")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)

                    Text("전체 메뉴 로딩 후 다시 확인해주세요")
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity, minHeight: 300)

            } else {
                SeasonCarouselView(
                    items: vm.seasonItems,
                    onSelectMenu: onSelectMenu,
                    onToggleBookmark: { vm.toggleBookmark(id: $0) }
                )
            }

        } else {

            // ✅ 일반 카테고리
            Mainpage_DefaultListView(
                items: vm.normalItems(for: selectedCategory),
                onToggleBookmark: { vm.toggleBookmark(id: $0) },
                onSelectMenu: onSelectMenu
            )
        }
    }
}
