//
//  Components.swift
//  Devkeeters_26
//
//  Shared "Pale Earth & Glass" UI building blocks — replaces the
//  hand-rolled RoundedRectangle card / capsule button patterns that were
//  previously duplicated per-screen.
//

import SwiftUI

// MARK: - Glass Card

private struct GlassCardModifier: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusLG, style: .continuous)
                    .fill(Color.theme.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeMetrics.radiusLG, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.theme.primary.opacity(0.05), radius: 20, x: 0, y: 8)
    }
}

extension View {
    /// Wraps content in a "liquid glass" card: linen-tinted surface, soft
    /// inner light stroke, and an umber-tinted ambient glow instead of a
    /// hard black shadow.
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(padding: padding))
    }
}

// MARK: - Buttons

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.headlineMd)
            .foregroundStyle(Color.theme.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Capsule().fill(Color.theme.primary))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.bodyMd.weight(.medium))
            .foregroundStyle(Color.theme.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.theme.secondaryContainer))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.theme.bodyMd.weight(.medium))
            .foregroundStyle(Color.theme.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().strokeBorder(Color.theme.primary, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var themePrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var themeSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var themeGhost: GhostButtonStyle { GhostButtonStyle() }
}

// MARK: - Pill Chip

/// Small pill-shaped label — restaurant picker, menu-item tags, confidence
/// badges. Uses the mono "label-sm" font to stand in for JetBrains Mono.
struct PillChip: View {
    var text: String
    var systemImage: String? = nil
    var tint: Color = .theme.onSurfaceVariant
    var background: Color = .theme.accentWarm

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.theme.labelSm)
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(background))
    }
}

// MARK: - Icon Badge

/// Circular muted-umber icon badge used for feature rows / section headers.
struct IconBadge: View {
    var systemImage: String
    var diameter: CGFloat = 40

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * 0.42, weight: .medium))
            .foregroundStyle(Color.theme.primary)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Color.theme.accentWarm))
    }
}
