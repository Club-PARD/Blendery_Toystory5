import SwiftUI

struct StoreSelectPanel: View {
    let onClose: () -> Void

    // ✅ 현재 선택된 매장 (UI 표시용)
    @State private var selectedStoreID: String = "ediya"

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("등록된 매장")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 0) {

                storeRow(
                    id: "ediya",
                    logoName: "이디야 로고",
                    selectedID: selectedStoreID
                ) {
                    selectedStoreID = "ediya"
                    print("이디야 1호점")
                }

                Divider()

                storeRow(
                    id: "starbucks",
                    logoName: "스벅 로고",
                    selectedID: selectedStoreID
                ) {
                    selectedStoreID = "starbucks"
                    print("스벅 1호점")
                }

                Divider()

                storeRow(
                    id: "dessamgu",
                    logoName: "데삼구 로고",
                    selectedID: selectedStoreID
                ) {
                    selectedStoreID = "dessamgu"
                    print("데삼구 1호점")
                }
            }
        }
        .padding(16)
    }

    // ✅ 로고 옆에 "선택 표시 빨간 점" 붙이는 row
    private func storeRow(
        id: String,
        logoName: String,
        selectedID: String,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 10) {

                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 105, height: 11)

                // ✅ 선택된 매장일 때만 빨간 동그라미 표시
                if selectedID == id {
                    Circle()
                        .fill(Color(red: 226/255, green: 49/255, blue: 0/255)) // 너네 쓰는 빨강 톤
                        .frame(width: 8, height: 8)
                        .padding(.leading, 2)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StoreSelectPanel(onClose: {})
}
