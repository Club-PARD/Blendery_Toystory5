import Foundation
import Combine

@MainActor
final class DetailRecipeViewModel: ObservableObject {
    
    // MARK: - Data
    @Published var menu: MenuCardModel? = nil
    
    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Option State (⭐️ 핵심)
    @Published var selectedTemperature: Temperature = .hot
    @Published var selectedSize: Size = .large
    
    // MARK: - Server Key (computed)
    var optionKey: String {
        RecipeOptionKey.make(
            temperature: selectedTemperature,
            size: selectedSize
        )
    }
    
    var optionBadgeTags: [String] {
            RecipeVariantType(rawValue: optionKey)?.optionTags ?? []
        }
    
    var currentSteps: [RecipeStep] {
        menu?.recipesByOption[optionKey]
        ?? menu?.recipesByOption.values.first
        ?? []
    }
    
    // MARK: - API
    func fetchRecipeDetail(recipeId: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let recipe = try await BlenderyAPI.shared.fetchRecipeDetail(
                recipeId: recipeId
            )

            self.menu = MenuCardModel.from(recipe)

            // ✅ 옵션 디버그
            print("현재 옵션 키:", optionKey)

        } catch APIError.unauthorized {
            errorMessage = "로그인이 만료되었습니다."
            TokenStore.clear()

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
