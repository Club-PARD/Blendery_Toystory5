//
//  RecipeTitle.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeTitle: View {
    let menu: MenuCardModel
    let optionTags: [String]
    let thumbnailURL: URL?

    // ⭐️ 상태는 부모에서 내려받음
    @Binding var isBookmarked: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack {
            // 썸네일
            ZStack {
                Rectangle()
                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)

                if let url = thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit().frame(width: 70, height: 70)
                        default:
                            Image("상세 로딩")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                    }
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

                    FavoriteButton(
                        isFavorite: $isBookmarked,
                        onToggle: onToggleFavorite
                    )
                }

                Text(menu.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
