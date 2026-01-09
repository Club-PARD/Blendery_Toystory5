////
////  temp_Data.swift
////  Blendery
////
////  Created by 박성준 on 12/28/25.
////
//
import Foundation

let categories: [String] = [
    "즐겨찾기",
    "시즌메뉴",
    "커피",
    "콜드브루",
    "논커피",
    "에이드&과일주스",
    "블렌디드",
    "티"
]

struct MenuCardModel: Identifiable, Hashable {
    let id: UUID
    let category: String
    let tags: [String]
    let title: String
    let subtitle: String
    var lines: [String]
    let recipesByOption: [String: [RecipeStep]]
    var isBookmarked: Bool
    var isImageLoading: Bool
    var imageName: String?
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    // ✅ 추가: 카드 대표 옵션 키(= Detail의 optionKey랑 같은 의미)
    let defaultOptionKey: String?

    // ✅ 추가: Detail과 동일 방식으로 배지 태그 계산
    var optionBadgeTags: [String] {
        RecipeVariantType(rawValue: defaultOptionKey ?? "")?.optionTags ?? []
    }

    // ✅ 카드에서 배지로 뭘 보여줄지 통합(옵션태그 우선, 없으면 기존 tags)
    var badgeTags: [String] {
        !optionBadgeTags.isEmpty ? optionBadgeTags : tags
    }
}
