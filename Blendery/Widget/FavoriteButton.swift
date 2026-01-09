//
//  FavoriteButton.swift
//  Blendery
//

import SwiftUI

struct FavoriteButton: View {
    let isFavorite: Bool
    let onTap: () -> Void

    private let favoriteRed = Color(red: 238/255, green: 34/255, blue: 42/255)

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                .renderingMode(.template)
                .resizable()
                .frame(width: 15.2, height: 18.25)
                .foregroundColor(isFavorite ? favoriteRed : .black)
        }
        .buttonStyle(.plain)
    }
}
