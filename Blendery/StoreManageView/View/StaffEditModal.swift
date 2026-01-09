import SwiftUI

// ===============================
//  StaffEditModal.swift
// ===============================

struct StaffEditModal: View {

    // [입력 변수]
    let member: StaffMember
    let onSave: (StaffMember) -> Void
    let onClose: () -> Void

    // [상태 변수]
    @State private var showChangeConfirm: Bool = false
    @State private var pendingRole: StaffMember.Role? = nil


    var body: some View {
        ZStack {
            // ✅ 모달 배경: 흰색
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 14) {

                Text("직급 변경")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 6)

                // ✅ 사각형 1개 안에 2개 버튼 + 구분선
                VStack(spacing: 0) {
                    roleRow(.manager)

                    Divider()
                        .background(Color.black.opacity(0.08))
                        .padding(.horizontal, 12)

                    roleRow(.staff)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95)) // ✅ 내부: 회색
                )
                .padding(.top, 6)

                Spacer()
            }
            .padding(24)
        }

        // ✅ 핵심: 시트 위에 또 하나의 "전체화면 레이어"로 경고창 올리기
        // → 그래서 모달 닫지 않아도 경고창 터치 가능
        .fullScreenCover(isPresented: $showChangeConfirm) {
            changeConfirmOverlayFullScreen()
                .presentationBackground(.clear) // iOS 16+
        }
    }

    // ===============================
    //  액션 로직
    // ===============================

    // 같은 직급이면 무시(모달 유지)
    // 다른 직급이면 경고창 열기
    private func requestRoleChange(_ role: StaffMember.Role) {
        guard member.role != role else { return }
        pendingRole = role
        showChangeConfirm = true
    }

    private func confirmRoleChange() {
        guard let role = pendingRole else { return }

        var updated = member
        updated.role = role
        onSave(updated)     // ✅ 반영
        showChangeConfirm = false
        pendingRole = nil
        onClose()           // ✅ 모달 닫기
    }

    private func cancelRoleChange() {
        showChangeConfirm = false
        pendingRole = nil
        // ✅ 모달은 유지
    }

    // ===============================
    //  UI 컴포넌트
    // ===============================

    private func roleRow(_ role: StaffMember.Role) -> some View {
        let isSelected = (member.role == role)

        return Button {
            requestRoleChange(role)
        } label: {
            HStack {
                Text(role.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // ✅ “화면 전체”에서 중앙에 뜨는 커스텀 경고창 (모달 위에서 동작)
    private func changeConfirmOverlayFullScreen() -> some View {
        ZStack {
            // 딤 처리 (전체 화면)
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { } // 바깥 탭 무시

            // ✅ 팝업: 화면 정중앙
            VStack(spacing: 12) {
                Image("느낌표")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 96) // ✅ 요청한 크기

                Text("직급을 변경하시겠습니까?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)

                HStack(spacing: 10) {
                    Button {
                        cancelRoleChange()
                    } label: {
                        Text("취소")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 0.92, green: 0.92, blue: 0.92))
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        confirmRoleChange()
                    } label: {
                        Text("변경")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.black)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 6)
            }
            .padding(18)
            .frame(maxWidth: 290)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
        }
    }
}
