//
//  MainModels_ViewModels.swift
//  Blendery
//
//  ✅ TopMenuViewModel + SearchBarViewModel + MainpageViewModel 통합 파일
//

import SwiftUI
import Combine
import Foundation

// ===============================
//  토스트 데이터 타입
// ===============================
struct ToastData: Identifiable, Equatable {
    let id = UUID()
    let iconName: String?
    let message: String
}

// ===============================
//  MainpageViewModel
// ===============================
@MainActor
final class MainpageViewModel: ObservableObject {

    // --------------------------------
    //  로컬 캐시 키
    // --------------------------------
    private let menuStorageKey = "menu_cache_cards_v1"

    // --------------------------------
    //  ✅ 전체 메뉴 누적 캐시 (앱 재실행해도 유지)
    // --------------------------------
    @Published private(set) var allCards: [MenuCardModel] = []

    // ✅ 화면에서 기존처럼 쓰는 cards (여기서는 allCards와 동일하게 유지)
    @Published var cards: [MenuCardModel] = []

    @Published var toast: ToastData? = nil

    // --------------------------------
    //  카테고리 매핑
    // --------------------------------
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

    // --------------------------------
    //  ✅ 시즌 메뉴로 보여줄 이름 6개 (서버 title이 완전일치)
    // --------------------------------
    private let seasonNames: Set<String> = [
        "멜팅 피스타치오",
        "너티초콜릿",
        "생과일 제주 감귤 주스",
        "딸기 자두 요구르트",
        "치즈폼 딸기라떼",
        "딸기 감귤티"
    ]

    // --------------------------------
    //  init: ✅ 앱 시작 시 로컬 먼저 로드
    // --------------------------------
    init() {
        loadMenuCacheFromDisk()
        cards = allCards
    }

    // --------------------------------
    //  ✅ 시즌 아이템: allCards에서 title로 필터
    // --------------------------------
    var seasonItems: [MenuCardModel] {
        allCards.filter { seasonNames.contains($0.title) }
    }

    // --------------------------------
    //  ✅ 즐겨찾기 아이템
    // --------------------------------
    var favoriteItems: [MenuCardModel] {
        allCards.filter { $0.isBookmarked }
    }

    // --------------------------------
    //  ✅ 일반 카테고리 아이템
    // --------------------------------
    func normalItems(for selectedCategory: String) -> [MenuCardModel] {
        guard let serverCategory = categoryMap[selectedCategory] else { return [] }
        return allCards.filter { $0.category == serverCategory }
    }

    // --------------------------------
    //  ✅ 서버 fetch (받아오면 allCards 누적/병합 + 로컬 저장)
    // --------------------------------
    func fetchRecipes(
        userId: String,
        franchiseId: String,
        category: String? = nil,
        favorite: Bool? = nil
    ) async {

        do {
            let recipes = try await APIClient.shared.fetchRecipes(
                franchiseId: franchiseId,
                category: category,
                favorite: favorite
            )

            let newCards = recipes.map { MenuCardModel.from($0) }

            // ✅ 누적 병합: 기존 즐겨찾기 상태(isBookmarked)는 유지
            var merged = allCards

            for new in newCards {
                if let idx = merged.firstIndex(where: { $0.id == new.id }) {
                    var keep = new
                    keep.isBookmarked = merged[idx].isBookmarked
                    merged[idx] = keep
                } else {
                    merged.append(new)
                }
            }

            allCards = merged
            cards = merged

            // ✅ 로컬 저장
            saveMenuCacheToDisk()

        } catch {
            print("❌ 레시피 목록 조회 실패:", error)
        }
    }

    // --------------------------------
    //  ✅ 즐겨찾기 토글 (allCards/cards + 로컬 저장)
    // --------------------------------
    func toggleBookmark(id: UUID) {
        guard let idx = allCards.firstIndex(where: { $0.id == id }) else { return }

        allCards[idx].isBookmarked.toggle()
        cards = allCards

        saveMenuCacheToDisk()

        toast = ToastData(
            iconName: "토스트 체크",
            message: allCards[idx].isBookmarked ? "즐겨찾기에 추가되었습니다." : "즐겨찾기가 해제되었습니다."
        )
    }

    func clearToast() {
        toast = nil
    }

    // --------------------------------
    //  masonry 분배
    // --------------------------------
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

    // --------------------------------
    //  (디버그) title 전부 찍기
    // --------------------------------
    func debugPrintTitles() {
        print("===== allCards titles =====")
        allCards.forEach { print("title:", $0.title) }
        print("===========================")
    }
}

// ===============================
//  ✅ 로컬 저장용 Cache 모델
// ===============================
private struct MenuCardCacheItem: Codable {
    let id: UUID
    let category: String
    let tags: [String]
    let title: String
    let subtitle: String
    let lines: [String]
    let isBookmarked: Bool

    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    // recipesByOption: [optionKey: [stepText]]
    let recipesByOption: [String: [String]]

    // 너가 MenuCardModel에 추가한 필드(있으면 유지)
    let defaultOptionKey: String?
}

// ===============================
//  로컬 저장/로드
// ===============================
private extension MainpageViewModel {

    func saveMenuCacheToDisk() {
        let cacheItems: [MenuCardCacheItem] = allCards.map { card in
            MenuCardCacheItem(
                id: card.id,
                category: card.category,
                tags: card.tags,
                title: card.title,
                subtitle: card.subtitle,
                lines: card.lines,
                isBookmarked: card.isBookmarked,
                hotThumbnailUrl: card.hotThumbnailUrl,
                iceThumbnailUrl: card.iceThumbnailUrl,
                recipesByOption: card.recipesByOption.mapValues { steps in
                    steps.map { $0.text }   // RecipeStep(text:)
                },
                defaultOptionKey: card.defaultOptionKey
            )
        }

        do {
            let data = try JSONEncoder().encode(cacheItems)
            UserDefaults.standard.set(data, forKey: menuStorageKey)
        } catch {
            print("❌ Menu cache encode failed:", error)
        }
    }

    func loadMenuCacheFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: menuStorageKey) else {
            allCards = []
            return
        }

        do {
            let cacheItems = try JSONDecoder().decode([MenuCardCacheItem].self, from: data)

            allCards = cacheItems.map { c in
                MenuCardModel(
                    id: c.id,
                    category: c.category,
                    tags: c.tags,
                    title: c.title,
                    subtitle: c.subtitle,
                    lines: c.lines,
                    recipesByOption: c.recipesByOption.mapValues { texts in
                        texts.map { RecipeStep(text: $0) }
                    },
                    isBookmarked: c.isBookmarked,
                    isImageLoading: false,
                    imageName: nil,
                    hotThumbnailUrl: c.hotThumbnailUrl,
                    iceThumbnailUrl: c.iceThumbnailUrl,
                    defaultOptionKey: c.defaultOptionKey
                )
            }

        } catch {
            print("❌ Menu cache decode failed:", error)
            allCards = []
        }
    }
}

// ===============================
//  SearchBarViewModel
// ===============================
@MainActor
final class SearchBarViewModel: ObservableObject {

    @Published var text: String = ""
    @Published var isFocused: Bool = false

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

    func search() async {
        guard hasText else {
            results = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            results = try await APIClient.shared.searchRecipes(keyword: text)
        } catch {
            print("❌ 검색 실패:", error)
            results = []
        }
    }
}

// ===============================
//  TopMenuViewModel
// ===============================
@MainActor
final class TopMenuViewModel: ObservableObject {

    @Published var categoryFrames: [String: CGRect] = [:]
    let categories: [String]

    private let favoriteRed = Color(red: 238/255, green: 34/255, blue: 42/255)
    private let seasonBlue = Color(red: 36/255, green: 60/255, blue: 131/255)

    init(categories: [String]) {
        self.categories = categories
    }

    func textColor(for category: String) -> Color {
        switch category {
        case "즐겨찾기":
            return favoriteRed
        case "시즌메뉴":
            return seasonBlue
        default:
            return .black
        }
    }

    func indicatorColor(for selectedCategory: String) -> Color {
        switch selectedCategory {
        case "즐겨찾기":
            return favoriteRed
        case "시즌메뉴":
            return seasonBlue
        default:
            return .black
        }
    }

    var favoriteKey: String { categories.first ?? "즐겨찾기" }

    func isFavorite(_ category: String) -> Bool {
        category == favoriteKey
    }
}
