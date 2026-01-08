// ===============================
//  StaffList_View.swift
//  Blendery
// ===============================

import SwiftUI
import UIKit

struct StaffList_View: View {
    
    //  상태/데이터 변수
    //  - UI만 먼저 만들기용(메모리 저장)
    @StateObject private var store = StaffStore()
    
    //  상태 변수
    //  - 편집할 멤버(선택된 멤버)
    @State private var selectedMember: StaffMember? = nil
    
    //  상태 변수
    //  - 추가 모달 표시
    @State private var showAddModal: Bool = false
    
    @State private var roleEditTarget: StaffMember? = nil
    @State private var deleteTarget: StaffMember? = nil

    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.97)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        sectionTitle("매니저")
                            .font(.system(size: 17, weight: .medium))

                        cardContainer {
                            memberList(
                                members: store.managers,
                                onTapEdit: { selectedMember = $0 }
                            )
                        }

                        sectionTitle("스태프")
                            .font(.system(size: 17, weight: .medium))

                        cardContainer {
                            memberList(
                                members: store.staffs,
                                onTapEdit: { selectedMember = $0 }
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
        .sheet(item: $selectedMember) { member in
            StaffEditModal(
                member: member,
                onSave: {
                    store.update($0)
                    selectedMember = nil
                },
                onDelete: {
                    store.delete($0)
                    selectedMember = nil
                },
                onClose: {
                    selectedMember = nil
                }
            )
            .presentationDetents([.fraction(0.7)])
        }
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
    }
}


// MARK: - UI 컴포넌트(내부)

private extension StaffList_View {
    
    // [레이아웃 상수]
    // - 사진 느낌 맞추기용
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
                            Button {
                                roleEditTarget = member
                            } label: {
                                Image("직원수정")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.gray)
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)

                            Button {
                                deleteTarget = member
                            } label: {
                                Image("직원삭제")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.gray)
                                    .frame(width: 30, height: 30)
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
    
    func editIcon() -> some View {
        if UIImage(named: "수정 아이콘") != nil {
            return AnyView(
                Image("수정 아이콘")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
            )
        } else {
            return AnyView(
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.gray)
            )
        }
    }
}
