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
            Image(isFavorite ? "즐찾아이콘" : "즐찾끔")
                .resizable()
                .frame(width: 15.2, height: 18.25)
        }
        .buttonStyle(.plain)
    }
}
