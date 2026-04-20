//
//  UserProfileStore.swift
//  PicSumFeed
//
//  Created by Mac Mini on 20/04/2026.
//
import SwiftUI
import PhotosUI
import Combine
@MainActor
final class UserProfileStore: ObservableObject {
    @Published var displayName: String = "Alejandro Escamilla"
    @Published var avatarImage: UIImage? = nil

    func setAvatar(from data: Data?) {
        guard let data, let img = UIImage(data: data) else { return }
        self.avatarImage = img
    }
}
