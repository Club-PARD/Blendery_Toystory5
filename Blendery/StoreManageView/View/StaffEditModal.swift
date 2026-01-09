//
//  StaffEditModal.swift
//  Blendery
//

import SwiftUI

// ===============================
//  StaffEditModal.swift
//  - 직급 변경 모달
//  - 경고창: "전체 화면 중앙" (fullScreenCover)
//  - 애니메이션: 최대한 억제(딱 뜨게)
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
            // ✅ 모달 배경
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
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                )
                .padding(.top, 6)

                Spacer()
            }
            .padding(24)
        }

        // ✅ 예전 위치 그대로: "전체 화면" 위에 띄우기
        .fullScreenCover(isPresented: $showChangeConfirm) {
            changeConfirmOverlayFullScreen()
                .presentationBackground(.clear) // iOS 16+
                .transaction { t in
                    // ✅ 전환 애니메이션 최대 억제
                    t.animation = nil
                    t.disablesAnimations = true
                }
        }
    }

    // ===============================
    //  액션 로직
    // ===============================

    private func requestRoleChange(_ role: StaffMember.Role) {
        guard member.role != role else { return }
        pendingRole = role
        presentConfirmNoAnimation()
    }

    private func confirmRoleChange() {
        guard let role = pendingRole else { return }

        var updated = member
        updated.role = role
        onSave(updated)

        dismissConfirmNoAnimation()
        pendingRole = nil
        onClose()
    }

    private func cancelRoleChange() {
        dismissConfirmNoAnimation()
        pendingRole = nil
    }

    // ✅ showChangeConfirm 토글을 애니메이션 없이
    private func presentConfirmNoAnimation() {
        var tr = Transaction()
        tr.animation = nil
        tr.disablesAnimations = true
        withTransaction(tr) {
            showChangeConfirm = true
        }
    }

    private func dismissConfirmNoAnimation() {
        var tr = Transaction()
        tr.animation = nil
        tr.disablesAnimations = true
        withTransaction(tr) {
            showChangeConfirm = false
        }
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

    // ✅ “화면 전체”에서 중앙에 뜨는 커스텀 경고창
    private func changeConfirmOverlayFullScreen() -> some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { } // 바깥 탭 무시

            VStack(spacing: 12) {
                Image("느낌표")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 96)

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
            // ✅ 중앙 “고정”
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    StaffEditModal(
        member: StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        onSave: { _ in },
        onClose: {}
    )
}
