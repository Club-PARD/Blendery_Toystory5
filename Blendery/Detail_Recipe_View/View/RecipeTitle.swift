//
//  RecipeTitle.swift
//  Blendery
//

import SwiftUI

struct RecipeTitle: View {
    let menu: MenuCardModel
    let optionTags: [String]
    let thumbnailURL: URL?

    @EnvironmentObject var favoriteStore: FavoriteStore

    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255, opacity: 1.0))
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)

                if let url = thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit()
                        default:
                            Image("상세 로딩")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                    }
                    .frame(width: 70, height: 70)
                } else {
                    Image("상세 로딩")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
            }

            VStack {
                HStack {
                    OptionBadge(tags: optionTags)
                        .padding(.bottom, 8)

                    Spacer()

                    // ✅ 즐겨찾기: FavoriteStore 기준
                    FavoriteButton(
                        isFavorite: favoriteStore.isFavorite(recipeId: menu.id),
                        onTap: { favoriteStore.toggle(card: menu) }
                    )
                }

                Text(menu.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
