//
//  Mainpage_View.swift
//  Blendery
//

import SwiftUI
import UIKit

struct Mainpage_View: View {
    var onLogout: (() -> Void)? = nil
    
    @EnvironmentObject var favoriteStore: FavoriteStore

    @State private var showStoreModal: Bool = false
    @State private var goStaffList: Bool = false
    @State private var selectedCategory: String = "즐겨찾기"

    @State private var toastMessage: String = ""
    @State private var toastIconName: String? = nil
    @State private var showToast: Bool = false

    // ✅ payload로 바꿈 (id + fallback)
    private struct RecipeNavPayload: Identifiable, Hashable {
        let id: UUID
        let fallback: MenuCardModel?
    }
    @State private var selectedRecipe: RecipeNavPayload? = nil

    private var userId: String? {
        SessionManager.shared.currentUserId
    }

    @StateObject private var vm = MainpageViewModel()
    @StateObject private var searchVM = SearchBarViewModel()

    @StateObject private var topMenuVM: TopMenuViewModel
    init(onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
        _topMenuVM = StateObject(wrappedValue: TopMenuViewModel(categories: categories))
    }

    @FocusState private var isSearchFieldFocused: Bool
    @State private var showProfile = false

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Mainpage_TopMenu(
                    onTapStoreButton: {
                        withAnimation(.easeInOut(duration: 0.25)) { showStoreModal = true }
                    },
                    onTapProfileButton: {
                        showProfile = true
                    },
                    onTapAdminButton: {
                        goStaffList = true
                    },
                    selectedCategory: $selectedCategory,
                    vm: topMenuVM
                )
                .background(Color.white)

                TabView(selection: $selectedCategory) {
                    ForEach(topMenuVM.categories, id: \.self) { category in
                        Mainpage_ScrollView(
                            selectedCategory: category,
                            vm: vm,
                            onSelectMenu: { menu in
                                // ✅ 여기! id + fallback 같이 넣어줌
                                selectedRecipe = RecipeNavPayload(id: menu.id, fallback: menu)
                            }
                        )
                        .tag(category)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: selectedCategory) { newCategory in
                    Task {
                        // ✅ 여기 추가: 시즌메뉴도 fetch 막기
                        if newCategory == "즐겨찾기" || newCategory == "시즌메뉴" { return }

                        let serverCategory = vm.serverCategory(from: newCategory)
                        guard let userId else {
                            print("🚫 userId 없음 - API 호출 차단")
                            return
                        }

                        await vm.fetchRecipes(
                            userId: userId,
                            franchiseId: "ac120003-9b6e-19e0-819b-6e8a08870001",
                            category: serverCategory
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if searchVM.isFocused {
                Mainpage_SearchOverlayView(
                    searchVM: searchVM,
                    focus: $isSearchFieldFocused,
                    onSelect: { recipeId in
                        // 검색은 서버에 있을 확률 높으니까 fallback nil로 OK
                        selectedRecipe = RecipeNavPayload(id: recipeId, fallback: nil)
                    }
                )
                .transition(.opacity)
                .zIndex(80)
            }

            if showStoreModal {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                    }
                    .zIndex(90)

                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Color.white
                            .frame(height: geo.safeAreaInsets.top)

                        StoreSelectPanel(
                            onClose: {
                                withAnimation(.easeInOut(duration: 0.2)) { showStoreModal = false }
                            }
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .background(Color.white)
                    .clipShape(RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight]))
                    .transition(.move(edge: .top))
                    .ignoresSafeArea(edges: .top)
                }
                .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden(true)

        .navigationDestination(isPresented: $showProfile) {
            ProfileView(
                profile: UserProfile(
                    name: "이지수",
                    role: "매니저",
                    joinedAt: "2010.12.25~",
                    phone: "010-7335-1790",
                    email: "l_oxo_l@handong.ac.kr"
                ),
                onLogout: onLogout
            )
        }

        .navigationDestination(isPresented: $goStaffList) {
            StaffList_View()
        }

        // ✅ 여기 핵심: DetailRecipeViewByID가 “서버 로딩 → DetailRecipeView(UI)”를 보여줌
        .navigationDestination(item: $selectedRecipe) { nav in
            DetailRecipeViewByID(
                recipeId: nav.id,
                allMenus: vm.cards,
                fallbackMenu: nav.fallback
            )
        }

        .onChange(of: vm.toast) { newToast in
            guard let newToast else { return }
            presentToast(newToast)
            vm.clearToast()
        }

        .overlay(alignment: .bottom) {
            if showToast {
                Toastmessage_View(message: toastMessage, iconName: toastIconName)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        
        .onChange(of: favoriteStore.toast) { newToast in
            guard let newToast else { return }
            presentToast(newToast)
            favoriteStore.clearToast()
        }

        .safeAreaInset(edge: .bottom, spacing: 0) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    SearchBarView(
                        vm: searchVM,
                        placeholder: "검색",
                        onSearchTap: { print("검색:", searchVM.text) },
                        focus: $isSearchFieldFocused
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .disabled(showStoreModal)
                    .allowsHitTesting(!showStoreModal)
                    .opacity(showStoreModal ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.18), value: showStoreModal)

                    Color.clear
                        .frame(height: geo.safeAreaInsets.bottom)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                .overlay(
                    RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .frame(height: 74)
        }
    }
}

private extension Mainpage_View {
    func presentToast(_ data: ToastData) {
        toastMessage = data.message
        toastIconName = data.iconName

        withAnimation(.easeOut(duration: 0.2)) { showToast = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.2)) { showToast = false }
        }
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}
