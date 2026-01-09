import Foundation
import Combine

@MainActor
final class FavoriteStore: ObservableObject {

    private let storageKey = "favorite_cache_items_v2"

    @Published private(set) var items: [FavoriteCacheItem] = []

    // ✅ 토스트 이벤트
    @Published var toast: ToastData? = nil

    init() {
        loadFromDisk()

        if items.isEmpty {
            seedNow()
        }

        // ✅ 구버전 데이터(옵션태그 기반) 저장돼있으면 1회 자동 수리
        Task { @MainActor in
            await repairLegacyItemsIfNeeded()
        }
    }

    var cards: [MenuCardModel] {
        items.map { $0.toMenuCardModel() }
    }

    func clearToast() {
        toast = nil
    }

    func isFavorite(recipeId: UUID) -> Bool {
        items.contains(where: { $0.recipeId == recipeId })
    }

    // ===============================
    //  즐겨찾기 토글
    //  - 저장 기준: defaultOptionKey(Detail과 동일)
    //  - key가 없으면 “lines와 steps 매칭”으로 찾음
    // ===============================
    func toggle(card: MenuCardModel) {
        if isFavorite(recipeId: card.id) {
            remove(recipeId: card.id)
            return
        }

        let key = bestOptionKeyForFavoriteSave(card: card)

        let newItem = FavoriteCacheItem(
            recipeId: card.id,
            title: card.title,
            category: card.category,
            subtitle: card.subtitle,
            lines: card.lines,
            hotThumbnailUrl: card.hotThumbnailUrl,
            iceThumbnailUrl: card.iceThumbnailUrl,

            // ✅ 신기준
            defaultOptionKey: key,

            // ✅ 구버전 필드(호환용) - 새로 저장할 땐 nil로
            optionTags: nil
        )

        items.insert(newItem, at: 0)
        saveToDisk()
        toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기에 추가되었습니다.")
    }

    func remove(recipeId: UUID) {
        items.removeAll(where: { $0.recipeId == recipeId })
        saveToDisk()
        toast = ToastData(iconName: "토스트 체크", message: "즐겨찾기가 해제되었습니다.")
    }
}

// ===============================
//  저장용 모델
//  - 구버전(v2): optionTags 저장
//  - 신버전: defaultOptionKey 저장 (Detail과 동일 방식)
// ===============================
struct FavoriteCacheItem: Codable, Identifiable, Hashable {

    let recipeId: UUID
    let title: String
    let category: String
    let subtitle: String
    var lines: [String]
    let hotThumbnailUrl: String?
    let iceThumbnailUrl: String?

    // ✅ NEW: 카드 “기본 레시피” 기준 옵션 키 (예: "HOT_LARGE")
    // 마이그레이션/수리에서 값을 채워야 하므로 var
    var defaultOptionKey: String?

    // ✅ OLD(v2): 기존 저장된 데이터 호환용 (마이그레이션/수리용)
    var optionTags: [String]?

    var id: UUID { recipeId }

    // ✅ 배지는 Detail과 동일: optionKey -> RecipeVariantType -> optionTags
    var computedBadgeTags: [String] {
        if let key = defaultOptionKey,
           let tags = RecipeVariantType(rawValue: key)?.optionTags {
            return tags
        }
        // 구버전 fallback(가능하면 남겨두지만, 수리되면 거의 안 씀)
        return optionTags ?? []
    }

    func toMenuCardModel() -> MenuCardModel {
        MenuCardModel(
            id: recipeId,
            category: category,
            tags: computedBadgeTags,
            title: title,
            subtitle: subtitle,
            lines: lines,
            recipesByOption: [:],
            isBookmarked: true,
            isImageLoading: false,
            imageName: nil,
            hotThumbnailUrl: hotThumbnailUrl,
            iceThumbnailUrl: iceThumbnailUrl,
            defaultOptionKey: defaultOptionKey
        )
    }
}

private extension FavoriteStore {

    // ===============================
    //  디스크 로드 + 1차 마이그레이션
    //  - defaultOptionKey가 없고 optionTags만 있으면 “대충” 변환
    //  - 근데 optionTags 자체가 예전 방식으로 잘못 저장됐을 수 있으니,
    //    init에서 repairLegacyItemsIfNeeded()로 “정확 수리”를 한 번 더 함
    // ===============================
    func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            items = []
            return
        }

        do {
            items = try JSONDecoder().decode([FavoriteCacheItem].self, from: data)

            // ✅ 1차 마이그레이션: defaultOptionKey가 없고 optionTags만 있으면 변환(정확하진 않을 수 있음)
            var changed = false
            for idx in items.indices {
                if items[idx].defaultOptionKey == nil,
                   let tags = items[idx].optionTags {
                    items[idx].defaultOptionKey = inferOptionKey(from: tags)
                    changed = true
                }
            }

            if changed {
                saveToDisk()
            }

        } catch {
            print("❌ FavoriteStore decode failed:", error)
            items = []
        }
    }

    func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ FavoriteStore encode failed:", error)
        }
    }

    // ===============================
    //  구버전 optionTags -> optionKey(대충) 변환
    //  tags 예: ["ICE","L"], ["HOT","XL"], ["HOT","EX"]
    // ===============================
    func inferOptionKey(from tags: [String]) -> String? {
        let temp = tags.first(where: { $0 == "ICE" || $0 == "HOT" })
        let size = tags.first(where: { $0 == "L" || $0 == "XL" || $0 == "EX" })

        switch (temp, size) {
        case ("ICE", "L"):
            return "ICE_LARGE"
        case ("ICE", "XL"), ("ICE", "EX"):
            return "ICE_EXTRA"
        case ("HOT", "L"):
            return "HOT_LARGE"
        case ("HOT", "XL"), ("HOT", "EX"):
            return "HOT_EXTRA"
        default:
            return nil
        }
    }

    // ===============================
    //  ✅ 핵심: “배지/내용 불일치”를 정확히 고치는 자동 수리
    //  - 구버전(optionTags가 남아있는 항목)만 대상으로
    //  - 서버 상세(variants) 받아서,
    //    즐찾에 저장된 lines(앞 3줄)과 가장 잘 맞는 variant.type을 찾아 defaultOptionKey를 교정
    // ===============================
    func repairLegacyItemsIfNeeded() async {
        let legacyIndices = items.indices.filter { items[$0].optionTags != nil }

        guard !legacyIndices.isEmpty else { return }

        var changed = false

        for idx in legacyIndices {
            let item = items[idx]

            do {
                let recipe = try await APIClient.shared.fetchRecipeDetail(recipeId: item.recipeId)

                // 즐찾에는 lines가 최대 3줄로 저장되어 있음(현재 너 로직)
                let target = item.lines

                let repairedKey = findMatchingVariantKey(
                    targetLines: target,
                    variants: recipe.variants
                )

                if items[idx].defaultOptionKey != repairedKey {
                    items[idx].defaultOptionKey = repairedKey
                    changed = true
                }

                // 수리가 끝났으면 구버전 표식을 제거(다음부터 수리 안 하게)
                items[idx].optionTags = nil
                changed = true

            } catch {
                // 서버 실패하면 일단 유지(다음 실행 때 다시 시도 가능)
                print("❌ favorite repair failed for \(item.recipeId):", error)
            }
        }

        if changed {
            saveToDisk()
        }
    }

    // targetLines(앞 3줄)과 variant.steps의 prefix가 가장 잘 맞는 variant를 찾음
    // 매칭 실패 시 서버 defaultVariant로 fallback
    func findMatchingVariantKey(
        targetLines: [String],
        variants: [RecipeVariantModel]
    ) -> String {

        // 1) target이 비어있으면 서버 default로
        if targetLines.isEmpty {
            let def = variants.first(where: { $0.isDefault }) ?? variants.first
            return def?.type.rawValue ?? "OTHER"
        }

        // 2) steps prefix가 완전히 같은 variant 우선
        for v in variants {
            let prefix = Array(v.steps.prefix(targetLines.count))
            if prefix == targetLines {
                return v.type.rawValue
            }
        }

        // 3) 못 찾으면 서버 default로
        let def = variants.first(where: { $0.isDefault }) ?? variants.first
        return def?.type.rawValue ?? "OTHER"
    }

    // ===============================
    //  즐겨찾기 저장 시 optionKey 결정
    //  - card.defaultOptionKey가 있으면 그걸로 확정
    //  - 없으면 card.lines와 recipesByOption을 매칭해서 찾음
    // ===============================
    func bestOptionKeyForFavoriteSave(card: MenuCardModel) -> String {
        if let key = card.defaultOptionKey, !key.isEmpty {
            return key
        }

        let target = Array(card.lines.prefix(3))
        if !target.isEmpty {
            for (key, steps) in card.recipesByOption {
                let stepTexts = steps.map { $0.text }
                let prefix = Array(stepTexts.prefix(target.count))
                if prefix == target {
                    return key
                }
            }
        }

        return card.recipesByOption.keys.first ?? "OTHER"
    }

    // ===============================
    //  처음 실행 mock 5개
    //  - 신기준: defaultOptionKey로 저장
    // ===============================
    func seedNow() {
        items = [
            FavoriteCacheItem(
                recipeId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: "아메리카노",
                category: "COFFEE",
                subtitle: "진한 에스프레소 + 물",
                lines: ["원두 분쇄", "추출 2샷", "물 200ml"],
                hotThumbnailUrl: nil,
                iceThumbnailUrl: nil,
                defaultOptionKey: "HOT_LARGE",
                optionTags: nil
            ),
            FavoriteCacheItem(
                recipeId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                title: "카페라떼",
                category: "COFFEE",
                subtitle: "에스프레소 + 우유",
                lines: ["우유 스팀", "추출 2샷", "우유 붓기"],
                hotThumbnailUrl: nil,
                iceThumbnailUrl: nil,
                defaultOptionKey: "HOT_EXTRA",
                optionTags: nil
            ),
            FavoriteCacheItem(
                recipeId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                title: "바닐라라떼",
                category: "COFFEE",
                subtitle: "바닐라 시럽 + 라떼",
                lines: ["시럽 15ml", "추출 2샷", "우유 200ml"],
                hotThumbnailUrl: nil,
                iceThumbnailUrl: nil,
                defaultOptionKey: "ICE_LARGE",
                optionTags: nil
            ),
            FavoriteCacheItem(
                recipeId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                title: "복숭아 아이스티",
                category: "TEA",
                subtitle: "티 베이스 + 시럽",
                lines: ["베이스 150ml", "시럽 20ml", "얼음 가득"],
                hotThumbnailUrl: nil,
                iceThumbnailUrl: nil,
                defaultOptionKey: "ICE_EXTRA",
                optionTags: nil
            ),
            FavoriteCacheItem(
                recipeId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                title: "자몽 에이드",
                category: "ADE",
                subtitle: "자몽 + 탄산",
                lines: ["자몽청 30ml", "탄산수 200ml", "얼음"],
                hotThumbnailUrl: nil,
                iceThumbnailUrl: nil,
                defaultOptionKey: "ICE_LARGE",
                optionTags: nil
            )
        ]
        saveToDisk()
    }
}
