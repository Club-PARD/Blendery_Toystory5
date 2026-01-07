import SwiftUI
import Combine

//  토스트 데이터 타입 (onChange 요구사항 때문에 Equatable)
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let iconName: String?
    let message: String
}

@MainActor
final class MainpageViewModel: ObservableObject {
    
    private let categoryMap: [String: String] = [
        "커피": "COFFEE",
        "콜드브루": "COLD_BREW",
        "디카페인": "DECAFEINE",
        "논커피": "NON_COFFEE",
        "블렌디드": "BLENDED",
        "티": "TEA",
        "에이드&과일주스": "ADE"
    ]

    func serverCategory(from uiCategory: String) -> String? {
        categoryMap[uiCategory]
    }
    
    @Published var cards: [MenuCardModel] = []
    @Published var toast: ToastData? = nil

    init() {}

    func fetchRecipes(
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async {

        do {
            let recipes = try await BlenderyAPI.shared.searchRecipes(
                franchiseId: franchiseId,
                category: category,
                favorite: favorite
            )

            self.cards = recipes.map {
                MenuCardModel.from($0)
            }

        } catch {
            print("❌ 레시피 목록 조회 실패:", error)
        }
    }


    var favoriteItems: [MenuCardModel] {
        cards.filter { $0.isBookmarked }
    }

    func normalItems(for selectedCategory: String) -> [MenuCardModel] {

        guard let serverCategory = categoryMap[selectedCategory] else {
            return []
        }

        return cards.filter { $0.category == serverCategory }
    }


    func toggleBookmark(id: UUID) {
        guard let idx = cards.firstIndex(where: { $0.id == id }) else { return }

        cards[idx].isBookmarked.toggle()
        cards = cards

        if cards[idx].isBookmarked == false {
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기가 해제되었습니다.")
        } else {
            toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기에 추가되었습니다.")
        }
    }

    func clearToast() {
        toast = nil
    }

    func distributeMasonry(
        items: [MenuCardModel],
        heights: [UUID: CGFloat],
        spacing: CGFloat = 17,
        defaultHeight: CGFloat = 200
    ) -> (left: [MenuCardModel], right: [MenuCardModel]) {

        var left: [MenuCardModel] = []
        var right: [MenuCardModel] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in items {
            let h = heights[item.id] ?? defaultHeight
            if leftH <= rightH {
                left.append(item)
                leftH += h + spacing
            } else {
                right.append(item)
                rightH += h + spacing
            }
        }
        return (left, right)
    }
}

//  검색창 뷰모델
@MainActor
final class SearchBarViewModel: ObservableObject {

    @Published var text: String = ""
    @Published var isFocused: Bool = false

    // ⭐️ 추가
    @Published var results: [SearchRecipeModel] = []
    @Published var isLoading: Bool = false

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func open() { isFocused = true }
    func clearText() {
        text = ""
        results = []
    }

    func close() {
        text = ""
        results = []
        isFocused = false
    }

    // ⭐️ 서버 검색
    func search() async {
        guard hasText else {
            results = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            results = try await BlenderyAPI.shared.searchRecipes(
                keyword: text
            )
        } catch {
            print("❌ 검색 실패:", error)
            results = []
        }
    }
}


//  탑메뉴 뷰모델
@MainActor
final class TopMenuViewModel: ObservableObject {
    @Published var categoryFrames: [String: CGRect] = [:]

    let categories: [String]
    let favoriteOrange = Color(red: 0.89, green: 0.19, blue: 0)

    init(categories: [String]) {
        self.categories = categories
    }

    var favoriteKey: String { categories.first ?? "즐겨찾기" }

    func isFavorite(_ category: String) -> Bool {
        category == favoriteKey
    }

    func indicatorColor(for selectedCategory: String) -> Color {
        isFavorite(selectedCategory) ? favoriteOrange : .black
    }

    func textColor(for category: String) -> Color {
        isFavorite(category) ? favoriteOrange : .black
    }
}
