//
//  AppRouter.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import SwiftUI
import Combine
@MainActor
final class AppRouter: ObservableObject {
    enum Route {
        case splash
        case feed
    }

    @Published var route: Route = .splash

    func goToFeed() {
        route = .feed
    }
}
