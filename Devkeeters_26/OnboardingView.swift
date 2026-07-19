//
//  OnboardingView.swift
//  Devkeeters_26
//
//  Onboarding slideshow introducing the "Cortex" concept, Siri shortcut
//  integration, and live tracking features. "Pale Earth & Glass" visual
//  language — soft blush ambient glow, umber text, capsule buttons. Slide
//  copy/topics are unchanged from before this reskin.
//

import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let slides = [
        OnboardingSlide(
            title: "Welcome to Cortex",
            description: "Your intelligent companion app for Quick Commerce. Orchestrate food, groceries, and local events using natural voice inputs.",
            iconName: "brain.head.profile"
        ),
        OnboardingSlide(
            title: "Hey Siri, Order My Usual",
            description: "Say \"order my Zomato usual\" and Siri will query availability, compute live totals, and place your order instantly — completely hands-free.",
            iconName: "mic.badge.plus"
        ),
        OnboardingSlide(
            title: "Real-time Live Activities",
            description: "Track your order stages directly on your lock screen and Dynamic Island. See ETAs adjust in real-time as your delivery progresses.",
            iconName: "mappin.and.ellipse"
        ),
        OnboardingSlide(
            title: "Crew Mode & Splits",
            description: "Collaborate with housemates on a single shared cart, coordinate plans, and enjoy automatic itemized bill splits seamlessly.",
            iconName: "person.3.sequence.fill"
        )
    ]

    var body: some View {
        ZStack {
            // Ambient background glow
            ambientGlow

            VStack(spacing: 0) {
                // Header (Skip Button)
                headerSection

                // Slide contents inside TabView
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideContent(slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Footer (Indicators & Next/Get Started Buttons)
                footerSection
            }
        }
    }

    // MARK: - Subviews

    private var ambientGlow: some View {
        GeometryReader { geo in
            ZStack {
                Color.theme.background.ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color.theme.secondaryContainer.opacity(0.6),
                        .clear
                    ],
                    center: .top,
                    startRadius: 50,
                    endRadius: geo.size.width * 0.9
                )
                .blur(radius: 30)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Spacer()
            if currentPage < slides.count - 1 {
                Button("Skip") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .font(.theme.bodyMd.weight(.medium))
                .foregroundStyle(Color.theme.onSurfaceVariant)
                .padding()
            } else {
                Spacer().frame(height: 44) // placeholder to maintain layout alignment
            }
        }
    }

    private func slideContent(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 32) {
            // Visual mark
            ZStack {
                Circle()
                    .fill(Color.theme.surfaceContainer)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                    )

                Image(systemName: slide.iconName)
                    .font(.system(size: 72))
                    .foregroundStyle(Color.theme.primary)
            }
            .padding(.top, 40)

            // Text content
            VStack(spacing: 16) {
                Text(slide.title)
                    .font(.theme.headlineLg)
                    .foregroundStyle(Color.theme.onSurface)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(slide.description)
                    .font(.theme.bodyLg)
                    .foregroundStyle(Color.theme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            Spacer()
        }
    }

    private var footerSection: some View {
        VStack(spacing: 24) {
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.theme.primary : Color.theme.outlineVariant)
                        .frame(width: currentPage == index ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }

            // Primary action button
            if currentPage < slides.count - 1 {
                Button("Continue") {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .buttonStyle(.themePrimary)
                .padding(.horizontal, 32)
            } else {
                Button("Get Started") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .buttonStyle(.themePrimary)
                .padding(.horizontal, 32)
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
