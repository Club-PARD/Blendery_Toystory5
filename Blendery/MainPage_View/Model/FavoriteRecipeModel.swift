//
//  FavoriteRecipeModel.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

import Foundation

struct FavoriteResponse: Decodable {
    let cafeId: String
    let favorites: [RecipeModel]
}
