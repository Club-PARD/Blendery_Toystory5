//
//  DetailRecipeView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

//
//  DetailRecipeView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct DetailRecipeView: View {
    let menu: MenuCardModel
    let allMenus: [MenuCardModel]        // ✅ 전체 메뉴 리스트를 같이 받음

    @StateObject private var searchVM = SearchBarViewModel()
    @FocusState private var isSearchFieldFocused: Bool

    @State private var selectedMenu: MenuCardModel? = nil  // ✅ 검색 결과 눌렀을 때 이동용

    var body: some View {
        ZStack {
            // ✅ 기본 상세 화면
            VStack(spacing: 0) {
                RecipeTitle(menu: menu)
                    .padding(22)

                // ✅ (기본) 현재 메뉴의 레시피 step은 그대로
                RecipeStepList(steps: menu.lines)
                    .padding(16)

                HStack {
                    Spacer()
                    OptionButton()
                        .padding(.trailing)
                }

                Spacer(minLength: 0)
            }

            // ✅ (메인페이지처럼) 검색 포커스면 전체 메뉴 리스트 오버레이
            if searchVM.isFocused {
                searchOverlay
                    .transition(.opacity)
                    .zIndex(50)
            }
        }
        // ✅ 하단 검색창 고정
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SearchBarView(
                vm: searchVM,
                placeholder: "메뉴 검색",
                onSearchTap: { print("검색:", searchVM.text) },
                focus: $isSearchFieldFocused
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color.white.opacity(0.95))
        }
        // ✅ 검색 결과 눌러서 다른 메뉴 상세로 이동
        .navigationDestination(item: $selectedMenu) { m in
            DetailRecipeView(menu: m, allMenus: allMenus)
        }
        // ✅ FocusState 동기화(메인페이지 방식)
        .onChange(of: searchVM.isFocused) { newValue in
            if isSearchFieldFocused != newValue { isSearchFieldFocused = newValue }
        }
        .onChange(of: isSearchFieldFocused) { newValue in
            if searchVM.isFocused != newValue { searchVM.isFocused = newValue }
        }
    }
}

// MARK: - 메인페이지처럼 "전체 메뉴 리스트" 오버레이
private extension DetailRecipeView {

    var searchedMenus: [MenuCardModel] {
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return allMenus }

        return allMenus.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }

    var searchOverlay: some View {
        let items = searchedMenus
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)

        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            if !q.isEmpty && items.isEmpty {
                VStack {
                    Spacer()
                    Text("검색 결과가 없어요")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(items) { item in
                            MenuListRow(
                                model: item,
                                onToggleBookmark: { },   // ✅ 상세 화면에서는 일단 토글 안씀(원하면 vm 넘겨서 연결 가능)
                                onSelect: {
                                    selectedMenu = item    // ✅ 탭하면 그 메뉴 상세로 이동
                                    closeSearch()
                                }
                            )
                        }
                    }
                    .padding(.bottom, 74)
                }
                .contentShape(Rectangle())
                .onTapGesture { }
            }
        }
    }

    func closeSearch() {
        searchVM.close()
        isSearchFieldFocused = false
        hideKeyboard()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
