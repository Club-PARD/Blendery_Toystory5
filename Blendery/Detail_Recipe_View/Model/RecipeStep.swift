//
//  Recipe.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//
import Foundation

struct RecipeStep: Identifiable, Hashable {
    let id = UUID()
    let text: String
}
