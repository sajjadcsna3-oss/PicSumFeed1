//
//  FeedImageItem.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import SwiftUI

enum FeedItemStatus: Equatable {
    case idle
    case loading
    case completed
    case failed(String)
    case cancelled
}

struct FeedImageItem: Identifiable, Equatable {
    let id: UUID
    let picsumID: String
    let author: String
    let url: URL

    var image: UIImage? = nil
    var status: FeedItemStatus = .idle

    // UI demo
    var isLiked: Bool = false
    var likeCount: Int = Int.random(in: 10...500)
    var commentCount: Int = Int.random(in: 0...120)

    // ✅ per-post avatar (so changing one won't affect all)
    var avatarImageData: Data? = nil

    init(id: UUID = UUID(), picsumID: String, author: String, url: URL) {
        self.id = id
        self.picsumID = picsumID
        self.author = author
        self.url = url
    }
}
