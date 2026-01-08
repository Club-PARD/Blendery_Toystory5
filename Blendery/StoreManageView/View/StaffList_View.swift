// ===============================
//  StaffList_View.swift
//  Blendery
// ===============================

import SwiftUI
import UIKit
import Combine

// ===============================
//  StaffList_View.swift
// ===============================

struct StaffList_View: View {

    // 상태/데이터 변수
    @StateObject private var store: StaffStore
    init(store: StaffStore = StaffStore()) {
        _store = StateObject(wrappedValue: store)
    }

    // 모달/팝업 트리거
    @State private var showAddModal: Bool = false
    @State private var roleEditTarget: StaffMember? = nil
    @State private var deleteTarget: StaffMember? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        sectionTitle("매니저")

                        cardContainer {
                            memberList(
                                members: store.managers,
                                onTapEdit: { roleEditTarget = $0 } // ✅ row 탭 → 편집 모달
                            )
                        }

                        sectionTitle("스태프")

                        cardContainer {
                            memberList(
                                members: store.staffs,
                                onTapEdit: { roleEditTarget = $0 } // ✅ row 탭 → 편집 모달
                            )
                        }

                        HStack {
                            Spacer()

                            Button {
                                showAddModal = true
                            } label: {
                                Text("추가 +")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, sidePadding + 6)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("직원 관리")
            .navigationBarTitleDisplayMode(.inline)
        }

        // ✅ 편집 모달 (수정 아이콘/row탭 공통)
        .sheet(item: $roleEditTarget) { member in
            StaffEditModal(
                member: member,
                onSave: {
                    store.update($0)
                    roleEditTarget = nil
                },
                onDelete: {
                    store.delete($0)
                    roleEditTarget = nil
                },
                onClose: {
                    roleEditTarget = nil
                }
            )
            .presentationDetents([.fraction(0.7)])
        }

        // ✅ 추가 모달
        .sheet(isPresented: $showAddModal) {
            StaffAddModal(
                onAdd: { name, date, role in
                    store.add(name: name, startDateText: date, role: role)
                    showAddModal = false
                },
                onClose: { showAddModal = false }
            )
            .presentationDetents([.fraction(0.7)])
        }

        // ✅ 삭제 확인 alert (삭제 아이콘 전용)
        .alert(
            "프로필을 삭제하시겠습니까!?",
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            )
        ) {
            Button("취소", role: .cancel) {
                deleteTarget = nil
            }
            Button("삭제", role: .destructive) {
                if let target = deleteTarget {
                    store.delete(target)
                }
                deleteTarget = nil
            }
        } message: {
            Text("삭제하면 되돌릴 수 없습니다.")
        }
    }
}

// MARK: - UI 컴포넌트(내부)
private extension StaffList_View {

    // 레이아웃 상수
    var sidePadding: CGFloat { 18 }
    var cardRadius: CGFloat { 20 }
    var rowVPadding: CGFloat { 14 }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, sidePadding + 6)
            .padding(.top, title == "매니저" ? 6 : 2)
    }

    func cardContainer(@ViewBuilder content: () -> some View) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03),
                            radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, sidePadding)
    }

    func memberList(
        members: [StaffMember],
        onTapEdit: @escaping (StaffMember) -> Void
    ) -> some View {

        VStack(spacing: 0) {

            if members.isEmpty {
                Text("등록된 프로필이 없습니다.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)

            } else {
                ForEach(Array(members.enumerated()), id: \.element.id) { idx, member in

                    HStack(spacing: 12) {

                        profileImage()
                            .frame(width: 46, height: 46)
                            .opacity(0.95)

                        VStack(alignment: .leading, spacing: 5) {

                            HStack(spacing: 6) {
                                Text(member.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.black)

                                roleBadge(member.role.rawValue)
                            }

                            Text(member.startDateText)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.gray.opacity(0.85))
                        }

                        Spacer()

                        HStack(spacing: 10) {
                            // ✅ 수정 아이콘 → 편집 모달
                            Button {
                                roleEditTarget = member
                            } label: {
                                Image("직원수정")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)

                            // ✅ 삭제 아이콘 → 삭제 alert
                            Button {
                                deleteTarget = member
                            } label: {
                                Image("직원삭제")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    // ✅ row 탭도 편집 모달로
                    .contentShape(Rectangle())
                    .onTapGesture { onTapEdit(member) }

                    .padding(.horizontal, 18)
                    .padding(.vertical, rowVPadding)

                    if idx != members.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0.86, green: 0.86, blue: 0.86))
                            .frame(height: 1)
                            .padding(.horizontal, 18)
                    }
                }
            }
        }
    }

    func roleBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.85))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    )
            )
    }

    func profileImage() -> some View {
        let img = UIImage(named: "직원관리프로필")
        ?? UIImage(systemName: "person.crop.circle.fill")!

        return Image(uiImage: img)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray)
    }
}

#Preview {
    let previewStore = StaffStore()
    previewStore.members = [
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        StaffMember(name: "김하늘", startDateText: "2022.03.01~", role: .manager),
        StaffMember(name: "박성준", startDateText: "2024.09.10~", role: .staff),
        StaffMember(name: "홍길동", startDateText: "2023.01.15~", role: .staff),
        StaffMember(name: "최예린", startDateText: "2025.06.07~", role: .staff),
    ]

    return StaffList_View(store: previewStore)
}
