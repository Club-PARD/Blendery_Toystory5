//
//  Mainpage_View.swift
//  Blendery
//
//  Created by 박성준 on 12/29/25.
//

import SwiftUI

struct Mainpage_View: View {

    // MARK: - State
    @State private var showStoreModal: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "즐겨찾기"

    // MARK: - Body
    var body: some View {
        ZStack {
            // ✅ 전체 배경
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ✅ 상단 메뉴
                Mainpage_TopMenu(
                    onTapStoreButton: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showStoreModal = true
                        }
                    },
                    categories: categories,
                    selectedCategory: $selectedCategory
                )
                .background(Color.white)

                // ✅ 카드 리스트 (카테고리 변경 시 레이아웃 초기화)
                Mainpage_ScrollView(
                    selectedCategory: selectedCategory
                )
                .id(selectedCategory)
            }

            // ✅ 매장 선택 모달
            if showStoreModal {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showStoreModal = false
                        }
                    }
                    .zIndex(9)

                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: geo.safeAreaInsets.top)

                        StoreSelectPanel(
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showStoreModal = false
                                }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    .clipShape(
                        RoundedCorner(
                            radius: 16,
                            corners: [.bottomLeft, .bottomRight]
                        )
                    )
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(edges: .top)
                }
                .zIndex(10)
            }
        }
        .navigationBarBackButtonHidden(true)

        // ✅ 하단 검색 패널
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    SearchBarView(
                        text: $searchText,
                        placeholder: "화이트초콜릿"
                    ) {
                        print("검색:", searchText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                    Color.clear
                        .frame(height: geo.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.95))
                .clipShape(
                    RoundedCorner(
                        radius: 30,
                        corners: [.topLeft, .topRight]
                    )
                )
                .overlay(
                    RoundedCorner(
                        radius: 30,
                        corners: [.topLeft, .topRight]
                    )
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .frame(height: 74)
        }
    }
}

// MARK: - RoundedCorner Shape
private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    Mainpage_View()
}
