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

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255, opacity: 1.0))
                    .frame(width: 68.17, height: 68.17)

                // ✅ 타이틀 이름으로 이미지가 있으면 쓰고, 없으면 기본 이미지
                if UIImage(named: menu.title) != nil {
                    Image(menu.title)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 37.5, height: 55.63)
                } else {
                    Image("상세 로딩")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                }
            }

            VStack {
                HStack {
                    OptionBadge(
                        tags: optionTags
                    )
                    .padding(.bottom, 8)
                    Spacer()
                    FavoriteButton()
                }

                Text(menu.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

//#Preview {
//    RecipeTitle(
//        menu: MenuCardModel(
//            category: "커피",
//            tags: ["ICE"], // ✅ 추가
//            title: "카페모카",
//            subtitle: "에스프레소 2샷",
//            lines: ["에스프레소 2샷", "초코소스 2펌프", "우유 윗선"],
//            isBookmarked: false
//        )
//    )
//}
