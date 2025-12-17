// PixelWishingBottleView.swift
// TaskPulse
//
// Pixel-style wishing bottle that fills with stars.

import SwiftUI

struct PixelWishingBottleView: View {
    let luckValue: Int
    var isActive: Bool = true

    private let maxStarsShown = 100

    @State private var stars: [PixelStar] = []
    @State private var pendingLuck: Int? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            PixelBottleView(stars: stars)
                .frame(width: 92, height: 120)
                .cosmicGlow(.electricCyan, radius: 6)

            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("气运值")
                        .font(.cosmicTitle3)
                        .foregroundColor(.cosmicTextPrimary)
                }

                Text("\(luckValue)")
                    .font(.cosmicMonoLarge)
                    .foregroundColor(.cosmicAmber)
                    .contentTransition(.numericText(value: Double(luckValue)))

                Text("完成任务会收集一颗星")
                    .font(.cosmicCaption2)
                    .foregroundColor(.cosmicTextSecondary)
            }

            Spacer(minLength: 0)
        }
        .onAppear {
            guard isActive else { return }
            // Clear stars for initial fill animation
            stars = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                syncStars(animated: true, targetValue: luckValue)
            }
        }
        .onChange(of: luckValue) { _, newValue in
            if isActive {
                syncStars(animated: true, targetValue: newValue)
            } else {
                pendingLuck = newValue
            }
        }
        .onChange(of: isActive) { _, newValue in
            guard newValue else { return }
            // Delay for tab/sheet transitions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let target = pendingLuck ?? luckValue
                pendingLuck = nil
                syncStars(animated: true, targetValue: target)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("气运值 \(luckValue)")
    }

    private func syncStars(animated: Bool, targetValue: Int) {
        let targetCount = min(max(targetValue, 0), maxStarsShown)

        if stars.count > targetCount {
            if animated {
                withAnimation(.easeOut(duration: 0.2)) {
                    stars = Array(stars.prefix(targetCount))
                }
            } else {
                stars = Array(stars.prefix(targetCount))
            }
            return
        }

        if stars.count < targetCount {
            let addCount = targetCount - stars.count
            let used = Set(stars.map(\.center))
            let newStars = makeStars(count: addCount, excluding: used)

            if animated {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    stars.append(contentsOf: newStars)
                }
            } else {
                stars.append(contentsOf: newStars)
            }
        }
    }

    private func makeStars(count: Int, excluding used: Set<PixelPoint>) -> [PixelStar] {
        guard count > 0 else { return [] }

        var available = PixelBottleArt.starCenters.filter { !used.contains($0) }
        available.shuffle()

        var chosen = Array(available.prefix(count))
        if chosen.count < count {
            var fallback = PixelBottleArt.starCenters.shuffled()
            while chosen.count < count, let next = fallback.first {
                fallback.removeFirst()
                chosen.append(next)
            }
        }

        return chosen.map { PixelStar(id: UUID(), center: $0) }
    }
}

// MARK: - Pixel Bottle
private struct PixelBottleView: View {
    let stars: [PixelStar]

    var body: some View {
        GeometryReader { geo in
            let pixelSize = floor(min(
                geo.size.width / CGFloat(PixelBottleArt.width),
                geo.size.height / CGFloat(PixelBottleArt.height)
            ))

            let contentWidth = pixelSize * CGFloat(PixelBottleArt.width)
            let contentHeight = pixelSize * CGFloat(PixelBottleArt.height)
            let origin = CGPoint(
                x: (geo.size.width - contentWidth) * 0.5,
                y: (geo.size.height - contentHeight) * 0.5
            )

            ZStack(alignment: .topLeading) {
                ForEach(PixelBottleArt.glassPixels, id: \.self) { p in
                    Rectangle()
                        .fill(Color.electricCyan.opacity(0.12))
                        .frame(width: pixelSize, height: pixelSize)
                        .offset(
                            x: origin.x + CGFloat(p.x) * pixelSize,
                            y: origin.y + CGFloat(p.y) * pixelSize
                        )
                }

                ForEach(PixelBottleArt.borderPixels, id: \.self) { p in
                    Rectangle()
                        .fill(Color.electricCyan.opacity(0.85))
                        .frame(width: pixelSize, height: pixelSize)
                        .offset(
                            x: origin.x + CGFloat(p.x) * pixelSize,
                            y: origin.y + CGFloat(p.y) * pixelSize
                        )
                }

                ForEach(stars) { star in
                    PixelStarView(center: star.center, pixelSize: pixelSize, origin: origin)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct PixelStarView: View {
    let center: PixelPoint
    let pixelSize: CGFloat
    let origin: CGPoint

    @State private var hasDroppedIn = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Self.starOffsets, id: \.self) { offset in
                Rectangle()
                    .fill(Color.cosmicAmber)
                    .frame(width: pixelSize, height: pixelSize)
                    .offset(
                        x: origin.x + CGFloat(center.x + offset.x) * pixelSize,
                        y: origin.y + CGFloat(center.y + offset.y) * pixelSize
                    )
            }
        }
        .shadow(color: Color.cosmicAmber.opacity(0.35), radius: pixelSize * 1.2)
        .opacity(hasDroppedIn ? 1 : 0)
        .offset(y: hasDroppedIn ? 0 : -pixelSize * 6)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                hasDroppedIn = true
            }
        }
    }

    fileprivate static let starOffsets: [PixelPoint] = [
        PixelPoint(x: 0, y: 0),
        PixelPoint(x: 1, y: 0),
        PixelPoint(x: -1, y: 0),
        PixelPoint(x: 0, y: 1),
        PixelPoint(x: 0, y: -1)
    ]
}

private struct PixelStar: Identifiable {
    let id: UUID
    let center: PixelPoint
}

private struct PixelPoint: Hashable {
    let x: Int
    let y: Int
}

private enum PixelBottleArt {
    static let template: [String] = [
        "       ####       ",
        "       ####       ",
        "        ##        ",
        "        ##        ",
        "       #..#       ",
        "      #....#      ",
        "     #......#     ",
        "     #......#     ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "    #........#    ",
        "     #......#     ",
        "     #......#     ",
        "      #....#      ",
        "       #..#       ",
        "        ##        ",
        "       ####       ",
        "      ######      ",
        "                  "
    ]

    static let width: Int = template.first?.count ?? 0
    static let height: Int = template.count

    static let borderPixels: [PixelPoint] = parse("#")
    static let glassPixels: [PixelPoint] = parse(".")
    static let starCenters: [PixelPoint] = {
        let glassSet = Set(glassPixels)
        return glassPixels.filter { center in
            PixelStarView.starOffsets.allSatisfy { offset in
                glassSet.contains(PixelPoint(x: center.x + offset.x, y: center.y + offset.y))
            }
        }
    }()

    private static func parse(_ character: Character) -> [PixelPoint] {
        var pixels: [PixelPoint] = []
        for (rowIndex, row) in template.enumerated() {
            for (columnIndex, ch) in row.enumerated() where ch == character {
                pixels.append(PixelPoint(x: columnIndex, y: rowIndex))
            }
        }
        return pixels
    }
}

#Preview {
    ZStack {
        Color.cosmicBlack.ignoresSafeArea()
        PixelWishingBottleView(luckValue: 7)
            .cosmicCard(padding: 20)
            .padding()
    }
    .preferredColorScheme(.dark)
}
