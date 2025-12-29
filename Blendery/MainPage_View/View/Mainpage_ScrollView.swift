import SwiftUI

private struct CardHeightKey: PreferenceKey {
    static var defaultValue: [UUID: CGFloat] = [:]
    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct Mainpage_ScrollView: View {
    let selectedCategory: String
    @State private var measuredHeights: [UUID: CGFloat] = [:]

    var body: some View {
        let filtered = filteredItems
        let columns = distributeMasonry(items: filtered, heights: measuredHeights)

        ScrollView {
            HStack(spacing: 17) {
                VStack(spacing: 17) {
                    ForEach(columns.left) { item in
                        MenuCardView(model: item)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: CardHeightKey.self,
                                        value: [item.id: geo.size.height]
                                    )
                                }
                            )
                    }
                }

                VStack(spacing: 17) {
                    ForEach(columns.right) { item in
                        MenuCardView(model: item)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: CardHeightKey.self,
                                        value: [item.id: geo.size.height]
                                    )
                                }
                            )
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.top, 17)
        }
        .onPreferenceChange(CardHeightKey.self) { new in
            if new != measuredHeights {
                measuredHeights = new
            }
        }
    }
}

private extension Mainpage_ScrollView {
    var filteredItems: [MenuCardModel] {
        if selectedCategory == "즐겨찾기" {
            return menuCardsMock.filter { $0.isBookmarked }
        } else {
            return menuCardsMock.filter { $0.category == selectedCategory }
        }
    }

    func distributeMasonry(
        items: [MenuCardModel],
        heights: [UUID: CGFloat]
    ) -> (left: [MenuCardModel], right: [MenuCardModel]) {

        var left: [MenuCardModel] = []
        var right: [MenuCardModel] = []
        var leftH: CGFloat = 0
        var rightH: CGFloat = 0

        for item in items {
            let h = heights[item.id] ?? 200
            if leftH <= rightH {
                left.append(item)
                leftH += h + 17
            } else {
                right.append(item)
                rightH += h + 17
            }
        }
        return (left, right)
    }
}

private struct MenuCardView: View {
    let model: MenuCardModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(model.tags, id: \.self) { t in
                        Text(t)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.71, green: 0.71, blue: 0.71).opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                    }
                    Spacer()
                }

                Text(model.title)
                    .font(.system(size: 18, weight: .bold))

                Text(model.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(model.lines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
    
            .padding(14)

            Image(model.isBookmarked ? "즐찾끔" : "즐찾아이콘")
                .resizable()
                .frame(width: 16, height: 16)
                .padding(12)
        }
    }
}
