//
//  Theme.swift
//  Devkeeters_26
//
//  "Pale Earth & Glass" design tokens, ported from the Stitch design spec at
//  ~/Downloads/stitch_onebrain_design_specification/pale_earth_glass/DESIGN.md.
//  No custom fonts are bundled, so typography approximates Manrope/Inter/
//  JetBrains Mono with SF Pro Rounded / SF Pro / SF Mono system designs.
//

import SwiftUI

extension Color {
    enum theme {
        // Backgrounds / surfaces
        static let background = Color(hex: 0xF9F9F6)
        static let surfaceContainerLow = Color(hex: 0xF4F4F1)
        static let surfaceContainer = Color(hex: 0xEEEEEB)
        static let surfaceContainerHigh = Color(hex: 0xE8E8E5)

        // Text / content
        static let onSurface = Color(hex: 0x1A1C1B)
        static let onSurfaceVariant = Color(hex: 0x504442)

        // Structure
        static let outline = Color(hex: 0x827471)
        static let outlineVariant = Color(hex: 0xD4C3BF)

        // Brand
        static let primary = Color(hex: 0x4E342E)
        static let onPrimary = Color(hex: 0xFFFFFF)
        static let secondaryContainer = Color(hex: 0xD7CCC8)
        static let accentWarm = Color(hex: 0xEFEBE9)

        // Semantic (desaturated per spec: "moss greens and dusty terracottas")
        static let success = Color(hex: 0x7A8471)
        static let warning = Color(hex: 0xB3735F)
        static let errorColor = Color(hex: 0xBA1A1A)
        static let errorContainer = Color(hex: 0xFFDAD6)
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Font {
    enum theme {
        // Stands in for Manrope 700 (display is desktop-scale in the spec; unused on phone-sized screens)
        static let display = Font.system(size: 40, weight: .bold, design: .rounded)
        // headline-lg-mobile: 24/600
        static let headlineLg = Font.system(size: 24, weight: .semibold, design: .rounded)
        // headline-md: 24/500
        static let headlineMd = Font.system(size: 20, weight: .medium, design: .rounded)
        // body-lg: 18/400 — stands in for Inter
        static let bodyLg = Font.system(size: 18, weight: .regular, design: .default)
        // body-md: 16/400
        static let bodyMd = Font.system(size: 16, weight: .regular, design: .default)
        // label-sm: 12/500, monospaced — stands in for JetBrains Mono
        static let labelSm = Font.system(size: 12, weight: .medium, design: .monospaced)
    }
}

enum ThemeMetrics {
    // Spacing, 8px base rhythm
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 12
    static let spacingBase: CGFloat = 8
    static let spacingMD: CGFloat = 24
    static let spacingLG: CGFloat = 48

    // Corner radii
    static let radiusSM: CGFloat = 4
    static let radiusDefault: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24
}
