//
//  DetailRecipeView.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct DetailRecipeView: View {
    var body: some View {
        VStack{
            RecipeTitle()
                .padding(22)
            RecipeStepList()
                .padding(16)
        }
    }
}

#Preview {
    DetailRecipeView()
}
