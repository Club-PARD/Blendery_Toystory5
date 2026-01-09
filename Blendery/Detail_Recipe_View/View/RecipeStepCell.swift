//
//  RecipeStepCell.swift
//  Blendery
//
//  Created by 박영언 on 12/26/25.
//

import SwiftUI

struct RecipeStepCell: View {
    let index: Int
    let step: RecipeStep

    var body: some View {
        HStack(spacing: 11) {

            // ✅ 숫자 원: 흰색
            Text("\(index)")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 170/255, green: 170/255, blue: 170/255, opacity: 1))
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(Circle())

            Text(step.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)

        // ✅ 리스트 사각형 배경: 연회색 (테두리 제거)
        .background(
            RoundedRectangle(cornerRadius: 10.71, style: .continuous)
                .fill(Color(red: 246/255, green: 246/255, blue: 246/255, opacity: 1))
        )
    }
}
