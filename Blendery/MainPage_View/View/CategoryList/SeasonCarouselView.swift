//
//  SeasonCarouselView.swift
//  Blendery
//
//  시즌 메뉴 캐러셀
//

import SwiftUI
import UIKit

struct SeasonCarouselView: View {

    // 서버 데이터
    let items: [MenuCardModel]

    // 화면 이동용 이벤트
    var onSelectMenu: (MenuCardModel) -> Void = { _ in }

    // 서버 호출 (즐겨찾기 토글)
    var onToggleBookmark: (UUID) -> Void = { _ in }

    // UI 레이아웃 상수
    private let cardWidth: CGFloat = 275
    private let cardHeight: CGFloat = 370
    private let spacing: CGFloat = 16
    private let topOffset: CGFloat = 80
    private let extraCenterScale: CGFloat = 0.06
    private var maxScale: CGFloat { 1.0 + extraCenterScale }

    // UI 무한 스크롤 느낌을 위한 복제 데이터
    private var loopItems: [LoopItem] {
        guard !items.isEmpty else { return [] }
        return (0..<5).flatMap { copy in
            items.map { LoopItem(copy: copy, item: $0) }
        }
    }

    // 캐러셀 중앙 카드 추적 상태
    @State private var focusedID: String?

    // 점프 중복 방지 상태
    @State private var isJumping = false

    // 인디케이터 표시용 계산값
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

                                // UI 스케일 계산
                                let baseScale = scaleForCard(geo: geo, outer: outer)
                                let isCenter = (focusedID == loop.id)
                                let xScale = baseScale * (isCenter ? 1.1 : 1.00)
                                let yScale = baseScale * (isCenter ? 1.15 : 1.00)

                                SeasonCard(
                                    item: loop.item,
                                    onToggleBookmark: { onToggleBookmark(loop.item.id) }
                                )
                                .frame(width: cardWidth, height: cardHeight)
                                .scaleEffect(x: xScale, y: yScale)

                                // ✅ (지지직 개선) 스크롤 중 계속 애니메이션 걸리는거 제거
                                // .animation(.easeOut(duration: 0.18), value: focusedID)

                                .contentShape(Rectangle())
                                .onTapGesture {
                                    let wasCentered = (focusedID == loop.id)

                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        focusedID = loop.id
                                    }

                                    if wasCentered {
                                        onSelectMenu(loop.item)
                                    }
                                }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                            .id(loop.id)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, topOffset)
                    .padding(.bottom, (cardHeight * extraCenterScale / 2) + 10)
                }
                .contentMargins(.horizontal, sideMargin, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $focusedID, anchor: .center)
                .onChange(of: focusedID) { newValue in
                    // UI 무한 스크롤 점프 트리거
                    guard let newValue,
                          let parsed = LoopItem.parse(id: newValue) else { return }
                    if parsed.copy == 1 || parsed.copy == 3 {
                        jumpToCenter(originalID: parsed.originalID)
                    }
                }
            }
            .frame(height: cardHeight * maxScale + topOffset + 16)

            indicatorView
                .padding(.bottom, 14)
        }
        .background(Color.clear)

        // UI 초기 위치 세팅
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

    // 무한 스크롤처럼 보이게 중앙 복귀
    private func jumpToCenter(originalID: UUID) {
        guard !isJumping else { return }
        isJumping = true

        let jumpID = LoopItem.makeID(copy: 2, originalID: originalID)

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

    // 중앙 확대 계산
    private func scaleForCard(geo: GeometryProxy, outer: GeometryProxy) -> CGFloat {
        let centerX = outer.size.width / 2
        let cardMidX = geo.frame(in: .scrollView(axis: .horizontal)).midX
        let distance = abs(cardMidX - centerX)

        let maxDistance = outer.size.width / 2
        let progress = min(distance / maxDistance, 1)

        return 1.0 - (progress * 0.12)
    }

    // 인디케이터 UI
    private var indicatorView: some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { idx in
                Circle()
                    .fill(idx == currentIndex ? Color(red: 0.11, green: 0.25, blue: 0.55) : Color.gray.opacity(0.35))
                    .frame(width: 9, height: 9)
            }
        }
        .padding(.vertical, 20)
    }
}

// UI 복제용 래퍼 모델
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

// ===============================
//  ✅ URL 이미지 뷰 (레이아웃 흔들림 방지용)
// ===============================
private struct RemoteMenuImageView: View {

    let urlString: String?

    var body: some View {
        let url = makeURL(urlString)

        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill() // ✅ 스크롤 중 레이아웃 흔들림 줄이려면 Fill이 안정적
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ 항상 같은 크기 유지
        .clipped()
    }

    private func makeURL(_ s: String?) -> URL? {
        guard let s, !s.isEmpty else { return nil }
        return URL(string: s)
    }

    private var placeholder: some View {
        ZStack {
            Color.white
            Image("loading")
                .resizable()
                .scaledToFit()
                .frame(width: 125, height: 125)
        }
    }
}

// 카드 UI
private struct SeasonCard: View {

    // 서버 데이터
    let item: MenuCardModel

    // 서버 호출 즐찾
    let onToggleBookmark: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(spacing: 0) {

                imageView
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)

                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: onToggleBookmark) {
                        Image(item.isBookmarked ? "즐찾아이콘" : "즐찾끔")
                            .resizable()
                            .frame(width: 14, height: 17)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )

            Text("NEW")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0.14, green: 0.24, blue: 0.51))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.top, 28)
                .padding(.trailing, 24)
        }
    }

    private var imageView: some View {

        // ✅ 1) 서버 썸네일 우선 (ICE 있으면 ICE, 없으면 HOT)
        let preferredURL: String? =
            (item.iceThumbnailUrl?.isEmpty == false ? item.iceThumbnailUrl : nil)
            ?? (item.hotThumbnailUrl?.isEmpty == false ? item.hotThumbnailUrl : nil)

        // ✅ 2) 로컬 이미지(타이틀과 같은 이름의 asset) fallback
        if let preferredURL {
            return AnyView(
                RemoteMenuImageView(urlString: preferredURL)
            )
        } else {
            let name = item.title
            if UIImage(named: name) != nil {
                return AnyView(
                    Image(name)
                        .resizable()
                        .scaledToFit()
                )
            } else {
                return AnyView(
                    RemoteMenuImageView(urlString: nil)
                )
            }
        }
    }
}
