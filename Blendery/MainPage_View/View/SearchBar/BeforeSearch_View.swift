//
//  BeforeSearch_View.swift
//  Blendery
//
//  Created by 박성준 on 1/9/26.
//

import SwiftUI

struct BeforeSearch_View: View {
    var body: some View {
        VStack {
            Image("검색")
                .resizable()
                .scaledToFit()
                .frame(width: 68, height: 90)
                .padding(.bottom, 24)
            
            Text("레시피를 검색해주세요.")
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .font(.system(size: 15))
                .padding(.bottom, 1)
            
                
        }
    }
}

#Preview {
    SearchEmpty_View()
}
