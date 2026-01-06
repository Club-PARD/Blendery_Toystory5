//
//  StaffEditModal_View.swift
//  Blendery
//
//  Created by 박성준 on 1/7/26.
//

import SwiftUI

struct StaffEditModal_View: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roleText: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                
                Text("편집")
                    .fontWeight(.bold)
                
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 50)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.71, green: 0.71, blue: 0.71), lineWidth: 1)
                        )
                    HStack {
                        Text("매니저")
                        Spacer()
                        Image("아래")
                            .resizable()
                            .frame(width: 18, height: 10)
                        
                    }
                    .padding(.horizontal, 15)
                }
                
                
                Spacer()
                
                
                
                Button(action: {
                    dismiss()
                }) {
                    Text("완료")
                        .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)                 // ✅ 글자색
                                .frame(maxWidth: .infinity, minHeight: 50) // ✅ 버튼 크기(가로 꽉, 높이 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.black)              // ✅ 버튼 배경색
                                )
                        
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("닫기")
                        .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.black)                 // ✅ 글자색
                                .frame(maxWidth: .infinity, minHeight: 50) // ✅ 버튼 크기(가로 꽉, 높이 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 0.97, green: 0.97, blue: 0.97))              // ✅ 버튼 배경색
                                )
                                .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(red: 0.53, green: 0.53, blue: 0.53), lineWidth: 1)
                                        )
                        
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    StaffAddModal()
}
