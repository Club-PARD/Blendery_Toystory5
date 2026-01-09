import SwiftUI

struct DetailRecipeViewByID: View {

    // 서버 변수
    let recipeId: UUID

    // 화면 구성용
    let allMenus: [MenuCardModel]

    // 즐찾 탭 seed 등 서버에 없을 때 fallback 표시용(선택)
    var fallbackMenu: MenuCardModel? = nil

    @State private var isLoading = true
    @State private var loadedMenu: MenuCardModel? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if let loadedMenu {
                // ✅ 네가 만든 UI로 보여줌
                DetailRecipeView(
                    menu: loadedMenu,
                    allMenus: allMenus
                )
            } else if let fallbackMenu {
                // ✅ 서버 실패 시에도 비어있지 않게 “로컬 step” 만들어서 표시
                DetailRecipeView(
                    menu: makeFallbackDetailMenu(from: fallbackMenu),
                    allMenus: allMenus
                )
            } else {
                VStack(spacing: 10) {
                    Text("상세 레시피를 불러오지 못했습니다")
                        .font(.system(size: 16, weight: .medium))
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .task {
            await load()
        }
    }

    @MainActor
    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let recipe = try await APIClient.shared.fetchRecipeDetail(recipeId: recipeId)

            // ✅ 서버 모델 -> UI 모델 (여기서 recipesByOption 채워져야 함)
            loadedMenu = MenuCardModel.from(recipe)
            errorMessage = nil
        } catch {
            print("❌ fetchRecipeDetail 실패:", error)
            loadedMenu = nil
            errorMessage = "서버 상세 조회 실패"
        }
    }

    // ✅ 서버가 없더라도 seed 카드가 “빈 상세”가 되지 않게
    private func makeFallbackDetailMenu(from card: MenuCardModel) -> MenuCardModel {
        // DetailRecipeViewModel이 steps를 읽을 수 있게 recipesByOption을 임시 구성
        let steps: [RecipeStep] = card.lines.map { RecipeStep(text: $0) }

        let copy = MenuCardModel(
            id: card.id,
            category: card.category,
            tags: card.tags,
            title: card.title,
            subtitle: card.subtitle,
            lines: card.lines,
            recipesByOption: ["OTHER": steps],
            isBookmarked: true,
            isImageLoading: false,
            imageName: nil,
            hotThumbnailUrl: card.hotThumbnailUrl,
            iceThumbnailUrl: card.iceThumbnailUrl,

            // ✅ 여기 추가
            defaultOptionKey: card.defaultOptionKey ?? "OTHER"
        )

        return copy
    }
}
