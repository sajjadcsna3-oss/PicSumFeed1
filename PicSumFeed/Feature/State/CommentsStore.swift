//
//  CommentsStore.swift
//  PicSumFeed
//
//  Created by Mac Mini on 20/04/2026.
//

import Foundation
import Combine
struct CommentItem: Identifiable, Equatable {
    let id = UUID()
    let user: String
    let text: String
    let time: String
}

@MainActor
final class CommentsStore: ObservableObject {
    @Published private(set) var comments: [UUID: [CommentItem]] = [:]

    func seedIfNeeded(for postID: UUID) {
        guard comments[postID] == nil else { return }
        comments[postID] = [
            CommentItem(user: "Ali", text: "Nice shot!", time: "1m"),
            CommentItem(user: "Sajjad", text: "Amazing view", time: "3m"),
            CommentItem(user: "Umar", text: "Looks great", time: "6m")
        ]
    }

    func list(for postID: UUID) -> [CommentItem] {
        comments[postID] ?? []
    }

    func addComment(postID: UUID, user: String, text: String) {
        let new = CommentItem(user: user, text: text, time: "now")
        comments[postID, default: []].insert(new, at: 0)
    }
}
