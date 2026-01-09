//
//  Mainpage_SearchOverlayView.swift
//  Blendery
//

//
//  Mainpage_SearchOverlayView.swift
//  Blendery
//

import SwiftUI
import UIKit

struct Mainpage_SearchOverlayView: View {

    @ObservedObject var searchVM: SearchBarViewModel
    var focus: FocusState<Bool>.Binding

    // ✅ 검색 결과 탭하면 UUID로 이동시키기
    var onSelect: (UUID) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            // ✅ 0) 검색창 들어왔는데 아직 입력이 없으면 BeforeSearch 보여주기
            if searchVM.isFocused && !searchVM.hasText {
                VStack {
                    Spacer()
                    BeforeSearch_View()
                        .padding(.bottom, -125) // 필요하면 SearchEmpty랑 동일하게 위치감 맞추기
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            // ✅ 1) 로딩 중
            } else if searchVM.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            // ✅ 2) 입력은 있는데 결과가 비었으면 Empty
            } else if searchVM.hasText && searchVM.results.isEmpty {
                VStack {
                    Spacer()
                    SearchEmpty_View()
                        .padding(.bottom, -125)
                    Spacer()
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            // ✅ 3) 결과 리스트
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchVM.results, id: \.recipeId) { r in
                            SearchResultRow(
                                title: r.title,
                                subtitle: r.category
                            )
                            .onTapGesture {
                                onSelect(r.recipeId)
                                closeSearch()
                            }

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

private struct SearchResultRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
