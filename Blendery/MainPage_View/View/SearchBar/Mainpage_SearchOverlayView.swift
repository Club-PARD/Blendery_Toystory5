//
//  Mainpage_SearchOverlayView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct Mainpage_SearchOverlayView: View {

    @ObservedObject var searchVM: SearchBarViewModel
    let results: [MenuCardModel]

    var onSelectMenu: (MenuCardModel) -> Void
    var onToggleBookmark: (UUID) -> Void
    var focus: FocusState<Bool>.Binding

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            if searchVM.hasText && results.isEmpty {
                // 🔹 검색어는 있는데 결과 없음
                VStack {
                    Spacer()
                    SearchEmpty_View()
                        .padding(.bottom, -125)
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 74)
                }

            } else {
                // 🔹 검색 결과 리스트
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results) { item in
                            MenuListRow(
                                model: item,
                                onToggleBookmark: { onToggleBookmark(item.id) },
                                onSelect: {
                                    onSelectMenu(item)
                                    closeSearch()
                                }
                            )

                            Divider()
                                .background(Color.gray.opacity(0.18))
                                .padding(.leading, 16)
                        }
                    }
                    .padding(.bottom, 74)
                }
            }
        }
    }

    // MARK: - Close
    private func closeSearch() {
        searchVM.close()
        focus.wrappedValue = false
        hideKeyboard()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

