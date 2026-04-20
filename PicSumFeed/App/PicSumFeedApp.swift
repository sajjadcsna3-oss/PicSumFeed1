//
//  PicSumFeedApp.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//

import SwiftUI

@main
struct PicSumFeedApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            switch router.route {
            case .splash:
                SplashView()
                    .environmentObject(router)
            case .feed:
                FeedView()
            }
        }
    }
}
