//
//  OptionModel.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import Foundation

enum Temperature: String {
    case hot = "HOT"
    case ice = "ICE"
}

enum Size: String {
    case large = "LARGE"
    case extra = "EXTRA"
}

struct RecipeOptionKey {
    static func make(
        temperature: Temperature,
        size: Size
    ) -> String {
        "\(temperature.rawValue)_\(size.rawValue)"
    }
}
