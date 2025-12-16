// DesignSystem.swift
// TaskPulse
//
// Cosmic Minimalism Design System

import SwiftUI

// MARK: - Color Palette
extension Color {
    // Core backgrounds - deep space
    static let cosmicBlack = Color(red: 0.04, green: 0.04, blue: 0.08)
    static let cosmicDeep = Color(red: 0.06, green: 0.07, blue: 0.12)
    static let cosmicSurface = Color(red: 0.10, green: 0.11, blue: 0.16)
    static let cosmicCard = Color(red: 0.12, green: 0.13, blue: 0.19)

    // Primary accent - electric cyan
    static let electricCyan = Color(red: 0.0, green: 0.87, blue: 0.97)
    static let electricCyanDim = Color(red: 0.0, green: 0.65, blue: 0.75)

    // Secondary accent - warm amber
    static let cosmicAmber = Color(red: 1.0, green: 0.72, blue: 0.25)
    static let cosmicAmberDim = Color(red: 0.85, green: 0.55, blue: 0.15)

    // Tertiary - soft lavender
    static let cosmicLavender = Color(red: 0.65, green: 0.55, blue: 0.95)
    static let cosmicLavenderDim = Color(red: 0.45, green: 0.38, blue: 0.75)

    // Status colors
    static let pulseSuccess = Color(red: 0.25, green: 0.88, blue: 0.55)
    static let pulseDanger = Color(red: 0.98, green: 0.35, blue: 0.42)
    static let pulseWarning = Color(red: 1.0, green: 0.78, blue: 0.28)
    static let pulseInfo = Color(red: 0.35, green: 0.68, blue: 0.98)

    // Text colors
    static let cosmicTextPrimary = Color(red: 0.95, green: 0.96, blue: 0.98)
    static let cosmicTextSecondary = Color(red: 0.58, green: 0.62, blue: 0.72)
    static let cosmicTextMuted = Color(red: 0.38, green: 0.42, blue: 0.52)
}

// MARK: - Typography
extension Font {
    // Display fonts - for large headers
    static let cosmicLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let cosmicTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let cosmicTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let cosmicTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body fonts
    static let cosmicHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let cosmicBody = Font.system(size: 17, weight: .regular, design: .rounded)
    static let cosmicCallout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let cosmicSubheadline = Font.system(size: 15, weight: .regular, design: .rounded)

    // Small fonts
    static let cosmicFootnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let cosmicCaption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let cosmicCaption2 = Font.system(size: 11, weight: .regular, design: .rounded)

    // Monospace for numbers
    static let cosmicMono = Font.system(size: 17, weight: .medium, design: .monospaced)
    static let cosmicMonoLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
}

// MARK: - Glassmorphism Effect
struct GlassBackground: View {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.08
    var borderOpacity: Double = 0.15

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white.opacity(opacity))
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity),
                                Color.white.opacity(borderOpacity * 0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Glow Effect Modifier
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius * 0.5)
            .shadow(color: color.opacity(0.3), radius: radius)
            .shadow(color: color.opacity(0.15), radius: radius * 2)
    }
}

extension View {
    func cosmicGlow(_ color: Color, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Pulse Animation
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                content
                    .foregroundColor(color)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulseEffect(_ color: Color) -> some View {
        modifier(PulseAnimation(color: color))
    }
}

// MARK: - Cosmic Button Style
struct CosmicButtonStyle: ButtonStyle {
    let color: Color
    let isSecondary: Bool

    init(color: Color = .electricCyan, isSecondary: Bool = false) {
        self.color = color
        self.isSecondary = isSecondary
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cosmicHeadline)
            .foregroundColor(isSecondary ? color : .cosmicBlack)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isSecondary {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(color, lineWidth: 2)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(color)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Cosmic Card Modifier
struct CosmicCard: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(GlassBackground(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func cosmicCard(padding: CGFloat = 16, cornerRadius: CGFloat = 20) -> some View {
        modifier(CosmicCard(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Animated Gradient Background
struct AnimatedCosmicBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.cosmicBlack,
                Color.cosmicDeep,
                Color(red: 0.08, green: 0.06, blue: 0.14),
                Color.cosmicBlack
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Noise Texture Overlay
struct NoiseOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for _ in 0..<Int(size.width * size.height * 0.003) {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let opacity = Double.random(in: 0.02...0.06)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                        with: .color(Color.white.opacity(opacity))
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Cosmic TextField Style
struct CosmicTextFieldStyle: TextFieldStyle {
    var icon: String? = nil

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.cosmicTextSecondary)
                    .font(.system(size: 18, weight: .medium))
            }
            configuration
                .font(.cosmicBody)
                .foregroundColor(.cosmicTextPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.cosmicSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Staggered Animation Helper
struct StaggeredAnimation: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(baseDelay + Double(index) * 0.08)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int, baseDelay: Double = 0.1) -> some View {
        modifier(StaggeredAnimation(index: index, baseDelay: baseDelay))
    }
}

// MARK: - Priority Color Extension (Cosmic Version)
extension Priority {
    var cosmicColor: Color {
        switch self {
        case .high: return .pulseDanger
        case .medium: return .cosmicAmber
        case .low: return .pulseSuccess
        }
    }

    var cosmicGradient: LinearGradient {
        switch self {
        case .high:
            return LinearGradient(
                colors: [.pulseDanger, .pulseDanger.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .medium:
            return LinearGradient(
                colors: [.cosmicAmber, .cosmicAmber.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .low:
            return LinearGradient(
                colors: [.pulseSuccess, .pulseSuccess.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
