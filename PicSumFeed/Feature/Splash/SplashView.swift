//
//  SplashView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                // App icon style
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)

                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("PicSum Feed")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(.label))

                Text("Discover. Scroll. Enjoy.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))

                Spacer()

                // Loading bar
                VStack(spacing: 10) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                        .frame(width: 220)

                    Text("Loading…")
                        .font(.footnote)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()
                    .frame(height: 30)
            }
            .padding(.horizontal, 24)
        }
        .task {
            // simple fake loading like screenshot
            progress = 0
            for i in 1...30 {
                try? await Task.sleep(nanoseconds: 30_000_000) // 0.03s
                progress = Double(i) / 30.0
            }
            router.goToFeed()
        }
    }
}
