//
//  SearchRecipeModel.swift
//  Blendery
//
//  Created by 박영언 on 1/5/26.
//

import Foundation

struct SearchRecipeModel: Codable, Identifiable {
    let recipeId: UUID
    let title: String
    let category: String
    let signature: Bool
    let new: Bool

    var id: UUID { recipeId }
}
