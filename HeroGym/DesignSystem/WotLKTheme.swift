import SwiftUI

/// Дизайн-система в стилистике World of Warcraft: Wrath of the Lich King
/// Ледяной синий (Frost / Ice Blue), глубокий нордический тёмный фон, благородные золотые акценты.
public enum WotLKTheme {
    // MARK: - Colors
    public static let bgDeep = Color(hex: 0x0A0E1A)
    public static let bgCard = Color(hex: 0x111827)
    public static let bgCardHover = Color(hex: 0x1A2238)
    public static let border = Color(hex: 0x1E3A5F)
    public static let borderGlow = Color(hex: 0x3B82F6)
    
    // Frost & Ice
    public static let iceLight = Color(hex: 0x93C5FD)
    public static let ice = Color(hex: 0x60A5FA)
    public static let iceBright = Color(hex: 0x38BDF8)
    public static let frost = Color(hex: 0xA5F3FC)
    
    // Gold
    public static let gold = Color(hex: 0xF59E0B)
    public static let goldLight = Color(hex: 0xFBBF24)
    public static let goldDark = Color(hex: 0x92400E)
    
    // Text
    public static let textPrimary = Color(hex: 0xF1F5F9)
    public static let textMuted = Color(hex: 0x94A3B8)
    public static let textSecondary = Color(hex: 0xCBD5E1)
    
    // Accent Badges
    public static let strengthOrange = Color(hex: 0xF97316)
    public static let cardioGreen = Color(hex: 0x22C55E)
    public static let cutRed = Color(hex: 0xEF4444)
    public static let xpPurple = Color(hex: 0xA855F7)
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Reusable Card Modifier
struct WotLKCardModifier: ViewModifier {
    var hasGlow: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                LinearGradient(
                    colors: [WotLKTheme.bgCard, Color(hex: 0x0F172A)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        hasGlow ? WotLKTheme.ice.opacity(0.6) : WotLKTheme.border,
                        lineWidth: 1
                    )
            )
            .cornerRadius(14)
            .shadow(
                color: hasGlow ? WotLKTheme.ice.opacity(0.18) : Color.black.opacity(0.4),
                radius: hasGlow ? 12 : 6,
                x: 0,
                y: 3
            )
    }
}

extension View {
    public func wotlkCard(hasGlow: Bool = false) -> some View {
        modifier(WotLKCardModifier(hasGlow: hasGlow))
    }
}
