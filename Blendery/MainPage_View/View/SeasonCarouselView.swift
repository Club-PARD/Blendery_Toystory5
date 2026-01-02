//
//  SeasonCarouselView.swift
//  Blendery
//
//  ✅ 방법 1: 5배 복제 + 가운데(copy=2)로 유지해서 "무한 스크롤"이 자연스럽게 느껴지게
//  ✅ 탭하면 onSelectMenu로 상세로 이동 가능
//

import SwiftUI
import UIKit

struct SeasonCarouselView: View {
    let items: [MenuCardModel]
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    private let cardWidth: CGFloat = 248
    private let cardHeight: CGFloat = 340
    private let spacing: CGFloat = 16
    private let topOffset: CGFloat = 100

    // ✅ 5배 복제 (0,1,2,3,4) / 가운데는 copy=2
    private var loopItems: [LoopItem] {
        guard !items.isEmpty else { return [] }
        return (0..<5).flatMap { copy in
            items.map { LoopItem(copy: copy, item: $0) }
        }
    }

    @State private var focusedID: String?       // "copy-uuid"
    @State private var isJumping = false

    // ✅ 인디케이터용 현재 인덱스
    private var currentIndex: Int {
        guard let focusedID,
              let parsed = LoopItem.parse(id: focusedID) else { return 0 }
        return items.firstIndex(where: { $0.id == parsed.originalID }) ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { outer in
                let sideMargin = max((outer.size.width - cardWidth) / 2, 0)
     
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: spacing) {
                        ForEach(loopItems) { loop in
                            GeometryReader { geo in
                                let scale = scaleForCard(geo: geo, outer: outer)

                                SeasonCard(item: loop.item)
                                    .frame(width: cardWidth, height: cardHeight)
                                    .scaleEffect(scale)
                                    .animation(.easeOut(duration: 0.18), value: scale)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            focusedID = loop.id
                                        }
                                        onSelectMenu(loop.item)
                                    }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .id(loop.id)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, topOffset)
                    .padding(.bottom, 0) // ✅ 6 없애기
                }
                .contentMargins(.horizontal, sideMargin, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $focusedID, anchor: .center)
                .onChange(of: focusedID) { newValue in
                    guard let newValue,
                          let parsed = LoopItem.parse(id: newValue) else { return }
                    if parsed.copy == 1 || parsed.copy == 3 {
                        jumpToCenter(originalID: parsed.originalID)
                    }
                }
            }
            .frame(height: cardHeight + topOffset) // ✅ +6 제거

            indicatorView
                .padding(.top, 8)      // ✅ 카드랑 간격
                .padding(.bottom, 6)
        }
        .background(Color.clear)       // ✅ 여기서 배경을 한 덩어리로 통일(필요시 Color.white로)
        .onAppear {
            if focusedID == nil, let first = items.first {
                let startID = LoopItem.makeID(copy: 2, originalID: first.id)
                var t = Transaction()
                t.animation = nil
                t.disablesAnimations = true
                withTransaction(t) { focusedID = startID }
            }
        }
    }

    // MARK: - Jump (중앙 copy=2로 복귀)
    private func jumpToCenter(originalID: UUID) {
        guard !isJumping else { return }
        isJumping = true

        let jumpID = LoopItem.makeID(copy: 2, originalID: originalID)

        // ✅ 스냅 애니메이션이 끝난 직후에 "무애니메이션 점프"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            var t = Transaction()
            t.animation = nil
            t.disablesAnimations = true
            withTransaction(t) { focusedID = jumpID }

            DispatchQueue.main.async {
                isJumping = false
            }
        }
    }

    // MARK: - Scale
    private func scaleForCard(geo: GeometryProxy, outer: GeometryProxy) -> CGFloat {
        let centerX = outer.size.width / 2
        let cardMidX = geo.frame(in: .scrollView(axis: .horizontal)).midX
        let distance = abs(cardMidX - centerX)

        let maxDistance = outer.size.width / 2
        let progress = min(distance / maxDistance, 1)

        return 1.0 - (progress * 0.12)
    }

    // MARK: - Indicator
    private var indicatorView: some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                Circle()
                    .fill(idx == currentIndex ? Color(red: 0.11, green: 0.25, blue: 0.55) : Color.gray.opacity(0.35))
                    .frame(width: 7, height: 7)
            }
        }
        .padding(.bottom, 6)
    }
}

// MARK: - LoopItem (원형 캐러셀용 래퍼)
private struct LoopItem: Identifiable {
    let copy: Int
    let item: MenuCardModel

    var id: String { "\(copy)-\(item.id.uuidString)" }

    static func makeID(copy: Int, originalID: UUID) -> String {
        "\(copy)-\(originalID.uuidString)"
    }

    static func parse(id: String) -> (copy: Int, originalID: UUID)? {
        let parts = id.split(separator: "-", maxSplits: 1).map(String.init)
        guard parts.count == 2, let c = Int(parts[0]), let uuid = UUID(uuidString: parts[1]) else { return nil }
        return (c, uuid)
    }
}

// MARK: - Card UI
private struct SeasonCard: View {
    let item: MenuCardModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 카드 전체를 한 번에 클립 → 경계선/띠 생길 확률 최소화
            VStack(spacing: 0) {

                // ✅ 이미지 영역 (상단)
                imageView
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .background(Color.white) // 혹시 이미지 투명일 때 대비
                    .clipped()

                // ✅ 하단 파란 영역 (딱 붙음)
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.orange)
                        .padding(.trailing, 2)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.11, green: 0.25, blue: 0.55))
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)

            // ✅ NEW 뱃지
            Text("NEW")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.11, green: 0.25, blue: 0.55))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(12)
        }
    }

    private var imageView: some View {
        let name = item.title
        if UIImage(named: name) != nil {
            return AnyView(
                Image(name)
                    .resizable()
                    .scaledToFit()
                    
            )
        } else {
            return AnyView(
                ZStack {
                    Color.white
                    Image("loading")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height:125)
                }
            )
        }
    }
}
