import SwiftUI

struct CardFavoriteButton: View {
    let isFavorite: Bool
    let onTap: () -> Void

    private let favoriteRed = Color(red: 0.88, green: 0.18, blue: 0.18)

    var body: some View {
        Button(action: onTap) {
            Image(isFavorite ? "즐찾아이콘" : "즐찾끔")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 17)
                .foregroundColor(favoriteRed)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 14) {
        CardFavoriteButton(isFavorite: true, onTap: {})
        CardFavoriteButton(isFavorite: false, onTap: {})
    }
    .padding()
}
