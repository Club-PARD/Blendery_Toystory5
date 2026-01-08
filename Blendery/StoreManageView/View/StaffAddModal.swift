// ===============================
//  StaffAddModal.swift
//  Blendery
//  (사진 UI 버전 + 발송 누르면 닫히기)
// ===============================

import SwiftUI
import Combine
import UIKit

struct StaffAddModal: View {

    // ===============================
    //  상태 변수
    // ===============================

    // - 이메일 입력값
    @State private var emailText: String = ""

    // ===============================
    //  콜백
    // ===============================

    // - 발송(실제 발송 X, 리스트로 돌아가게 + 토스트 띄우는 트리거만)
    let onSend: (String) -> Void

    // - 모달 닫기
    let onClose: () -> Void

    // ===============================
    //  UI
    // ===============================

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 14) {

                Text("직원 추가")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 10)

                // ✅ 사진처럼: 큰 회색 입력 박스 1개
                emailField()

                // ✅ 발송 버튼 (검은 배경 + 흰 글씨)
                sendButton()

                // ✅ 닫기 버튼 (흰 배경 + 검은 글씨)
                closeButton()

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 6)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // ===============================
    //  UI 컴포넌트
    // ===============================

    private func emailField() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.95, green: 0.95, blue: 0.95))

            TextField(
                "",
                text: $emailText,
                prompt: Text("000000@gmail.com")
                    .foregroundStyle(Color.gray.opacity(0.75))  // ✅ placeholder 회색
                    .font(.system(size: 18, weight: .regular))   // ✅ 글자 크기 살짝 줄임
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled(true)
            .font(.system(size: 18, weight: .regular))         // ✅ 입력 글자도 살짝 줄임
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(height: 64)
        }
        .frame(height: 64)
    }

    private func sendButton() -> some View {
        Button {
            let trimmed = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            // ✅ “발송” 눌렀을 때:
            // 1) 리스트 쪽에 토스트 띄우라고 알려주고
            // 2) 모달 닫기
            onSend(trimmed)
            onClose()

        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black)

                Text("초대메일 발송하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }

    private func closeButton() -> some View {
        Button {
            onClose()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )

                Text("닫기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StaffAddModal(
        onSend: { _ in },
        onClose: {}
    )
}
