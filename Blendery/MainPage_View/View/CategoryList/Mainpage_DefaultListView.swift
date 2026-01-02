//
//  Mainpage_DefaultListView.swift
//  Blendery
//
//  즐겨찾기, 시즌 메뉴 외 일반 카테고리 리스트 정렬 뷰
//

import SwiftUI

struct Mainpage_DefaultListView: View {

    // 서버 데이터
    // 서버에서 받은 메뉴 목록을 화면에 표시하기 위한 입력 데이터
    let items: [MenuCardModel]

    // 서버 호출
    // 즐겨찾기 변경 같은 서버 저장 작업을 바깥에서 처리하도록 트리거
    var onToggleBookmark: (UUID) -> Void = { _ in }

    // 화면 이동용 이벤트
    // 상세 화면 이동을 위해 선택된 메뉴를 바깥으로 전달
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {

                
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in

                    // 서버 데이터일 가능성 높음
                    // 한 줄 UI에 표시할 모델
                    MenuListRow(
                        model: item,

                        // 서버 호출로 이어질 가능성 있음
                        // 실제 저장은 바깥에서 구현
                        onToggleBookmark: { onToggleBookmark(item.id) },

                        // 화면 이동용 이벤트
                        onSelect: { onSelectMenu(item) }
                    )

                    // UI 구분선 표시용
                    if idx != items.count - 1 {
                        Divider()
                            .background(Color.gray.opacity(0.25))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color.white)
        }
    }
}
