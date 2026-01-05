//
//  RecipeStepList.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeStepList: View {
    let steps: [RecipeStep]
    var bottomInset: CGFloat = 10
    
    var body: some View {
        ScrollView {
            Text("레시피")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.regular)
                .padding(.leading, 8)
            
            VStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    RecipeStepCell(
                        index: index + 1,
                        step: step
                    )
                }
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: bottomInset)
        }
    }
}
