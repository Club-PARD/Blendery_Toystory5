//
//  Mainpage_SearchOverlayView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct Mainpage_SearchOverlayView: View {
    @ObservedObject var searchVM: SearchBarViewModel

    let allMenus: [MenuCardModel]
    var onToggleBookmark: (UUID) -> Void = { _ in }
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    var focus: FocusState<Bool>.Binding

    var body: some View {
        let items = searchedItems
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)

        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            if !q.isEmpty && items.isEmpty {
                VStack {
                    Spacer()
                    SearchEmpty_View()
                        .padding(.bottom, -125)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                            MenuListRow(
                                model: item,
                                onToggleBookmark: { onToggleBookmark(item.id) },
                                onSelect: { onSelectMenu(item) }
                            )

                            // ✅ 검색 리스트에도 구분선
                            if idx != items.count - 1 {
                                Divider()
                                    .background(Color.gray.opacity(0.18))
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .padding(.bottom, 74)
                    .background(Color.white)
                }
                .contentShape(Rectangle())
                .onTapGesture { }
            }
        }
    }

    // MARK: - Search Filter
    private var searchedItems: [MenuCardModel] {
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return allMenus }
        return allMenus.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.subtitle.localizedCaseInsensitiveContains(q) ||
            $0.lines.joined(separator: " ").localizedCaseInsensitiveContains(q)
        }
    }

    // MARK: - Close
    private func closeSearch() {
        searchVM.close()
        focus.wrappedValue = false
        hideKeyboard()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
