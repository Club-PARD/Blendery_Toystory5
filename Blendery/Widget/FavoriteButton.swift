//
//  FavoriteButton.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//
import SwiftUI

struct FavoriteButton: View {
    @State private var isFavorite = false

    var body: some View {
        Button {
            isFavorite.toggle()
        } label: {
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .resizable()
                .frame(width: 15.2, height: 18.25)
        }
        .buttonStyle(.plain)
    }
}
