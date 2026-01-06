//
//  StaffList_View.swift
//  Blendery
//
//  Created by 박성준 on 1/6/26.
//

import SwiftUI

struct StaffList_View: View {

    // ✅ [상태 변수] 어떤 모달을 띄울지
    private enum ActiveModal: Identifiable {
        case add
        case edit

        var id: Int {
            switch self {
            case .add: return 0
            case .edit: return 1
            }
        }
    }

    @State private var activeModal: ActiveModal? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Text("매장 관리")

                Text("매니저")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 360, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )

                    HStack {
                        Image("매장 관리 프로필")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)

                        VStack(alignment: .leading) {
                            Text("이지수")
                            Text("2010.12.25~")
                        }

                        Spacer()

                        // ✅ 수정 -> 편집 모달
                        Button(action: {
                            activeModal = .edit
                        }) {
                            Image("수정 아이콘")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)
                }

                Text("스태프")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding(.top, 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 360, height: 240)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )

                    VStack(spacing: 15) {

                        // --- 1번째 ---
                        HStack {
                            Image("매장 관리 프로필")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text("이지수")
                                Text("2010.12.25~")
                            }

                            Spacer()

                            Button(action: {
                                activeModal = .edit   // ✅ 수정 -> 편집
                            }) {
                                Image("수정 아이콘")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 40)

                        Rectangle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(height: 1)
                            .padding(.horizontal, 40)

                        // --- 2번째 ---
                        HStack {
                            Image("매장 관리 프로필")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text("이지수")
                                Text("2010.12.25~")
                            }

                            Spacer()

                            Button(action: {
                                activeModal = .edit   // ✅ 수정 -> 편집
                            }) {
                                Image("수정 아이콘")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 40)

                        Rectangle()
                            .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(height: 1)
                            .padding(.horizontal, 40)

                        // --- 3번째 ---
                        HStack {
                            Image("매장 관리 프로필")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text("이지수")
                                Text("2010.12.25~")
                            }

                            Spacer()

                            Button(action: {
                                activeModal = .edit   // ✅ 수정 -> 편집
                            }) {
                                Image("수정 아이콘")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 40)
                    }
                }

                HStack {
                    Spacer()

                    // ✅ 추가 -> 추가 모달
                    Button(action: {
                        activeModal = .add
                    }) {
                        Text("추가+")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white)
                            )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
            }
        }
        // ✅ 어떤 버튼 눌렀는지에 따라 다른 모달 띄우기
        .sheet(item: $activeModal) { modal in
            switch modal {
            case .add:
                StaffAddModal()
                    .presentationDetents([.fraction(0.7)])
                    .presentationDragIndicator(.visible)

            case .edit:
                StaffEditModal_View()
                    .presentationDetents([.fraction(0.7)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    StaffList_View()
}

