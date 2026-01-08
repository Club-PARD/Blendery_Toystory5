import SwiftUI

private struct CategoryFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_TopMenu: View {
    let onTapStoreButton: () -> Void
    let onTapProfileButton: () -> Void
    let onTapAdminButton: () -> Void
    
    @Binding var selectedCategory: String
    @ObservedObject var vm: TopMenuViewModel
    
    //  레이아웃 분기용
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isPadLayout: Bool { hSizeClass == .regular }
    
    var body: some View {
        VStack(spacing: 12) {
            
            Button(action: onTapStoreButton) {
                HStack {
                    Image("이디야 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 111, height: 10)
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .frame(width: 14, height: 8)
                        .foregroundColor(Color(red: 204/255, green: 204/255, blue: 204/255, opacity: 1))
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 20)
            .buttonStyle(.plain)
            
            HStack(spacing: 18) {
                Text("Blendery")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
                
                Button(action:onTapAdminButton)  {
                    Image("직원관리")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 23)
                }
                .buttonStyle(.plain)
                
                Button(action: onTapProfileButton) {
                    Image("사람")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)
            
            // ✅ 여기부터: iPad / iPhone 분기
            Group {
                if isPadLayout {
                    // ✅ iPad: 전체 폭 균등 분배 (스크롤 없음)
                    HStack(spacing: 0) {
                        ForEach(vm.categories, id: \.self) { category in
                            let isSelected = (selectedCategory == category)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            } label: {
                                Text(category)
                                    .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity)   // ⭐️ 균등 분배 핵심
                                    .frame(height: 33)
                                    .foregroundColor(vm.textColor(for: category))
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: CategoryFrameKey.self,
                                                value: [category: geo.frame(in: .named("CategoryScroll"))]
                                            )
                                        }
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                } else {
                    // ✅ iPhone: 지금처럼 가로 스크롤 유지
                    // ✅ iPhone: 지금처럼 가로 스크롤 유지 + 자동 따라가기
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(vm.categories, id: \.self) { category in
                                    let isSelected = (selectedCategory == category)
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        Text(category)
                                            .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                                            .lineLimit(1)
                                            .fixedSize(horizontal: true, vertical: false)
                                            .padding(.horizontal, 14)
                                            .frame(height: 33)
                                            .foregroundColor(vm.textColor(for: category))
                                            .background(
                                                GeometryReader { geo in
                                                    Color.clear.preference(
                                                        key: CategoryFrameKey.self,
                                                        value: [category: geo.frame(in: .named("CategoryScroll"))]
                                                    )
                                                }
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .id(category) // ✅ ScrollViewReader가 찾을 수 있게 id 부여
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                        
                        //  selectedCategory가 바뀔 때(= TabView 스와이프 포함) 자동 스크롤
                        .onChange(of: selectedCategory) { newValue in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                        
                        //  처음 진입 시에도 현재 선택값으로 위치 맞추기
                        .onAppear {
                            DispatchQueue.main.async {
                                proxy.scrollTo(selectedCategory, anchor: .center)
                            }
                        }
                    }
                    // ✅ indicator(밑줄) 로직은 iPad/iPhone 공통 적용
                    .coordinateSpace(name: "CategoryScroll")
                    .onPreferenceChange(CategoryFrameKey.self) { frames in
                        vm.categoryFrames = frames
                    }
                    .overlay(alignment: .bottomLeading) {
                        GeometryReader { _ in
                            if let f = vm.categoryFrames[selectedCategory] {
                                Rectangle()
                                    .fill(vm.indicatorColor(for: selectedCategory))
                                    .frame(width: f.width, height: 2)
                                    .offset(x: f.minX, y: 0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                            }
                        }
                        .frame(height: 2)
                    }
                }
            }
        }
    }
}
