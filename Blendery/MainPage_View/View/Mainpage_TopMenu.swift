import SwiftUI

struct Mainpage_TopMenu: View {
    let onTapStoreButton: () -> Void
    let categories: [String]
    @Binding var selectedCategory: String

    var body: some View {
        VStack(spacing: 12) {

            Button(action: onTapStoreButton) {
                HStack {
                    Image("이디야 로고")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 111, height: 10)

                    Image("아래")
                        .resizable()
                        .frame(width: 13, height: 10)

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)

            HStack {
                Text("Blendery")
                    .font(.system(size: 34, weight: .bold))
                Spacer()
                Image("사람")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.system(size: 13))
                                .frame(width: 63, height: 33)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
