//
//  StaffAddModal.swift
//  Blendery
//
//  Created by 박성준 on 1/7/26.
//

import SwiftUI

struct StaffAddModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roleText: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                
                Text("추가")
                    .fontWeight(.bold)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(red: 0.71, green: 0.71, blue: 0.71), lineWidth: 1)
                        )

                    HStack(spacing: 10) {
                        TextField("직책 입력", text: $roleText)
                            .font(.system(size: 16))
                            .frame(height: 50)
                            .padding(.leading, 15)

                        Spacer()

                        // ✅ [버튼] 한 번에 지우기
                        if !roleText.isEmpty {
                            Button(action: {
                                roleText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.gray)
                            }
                            .padding(.trailing, 20)
                            .buttonStyle(.plain)
                        }
                    }
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
