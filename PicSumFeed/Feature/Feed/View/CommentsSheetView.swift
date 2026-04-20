//
//  CommentsSheetView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 20/04/2026.
//
import SwiftUI

struct CommentsSheetView: View {
    @EnvironmentObject private var profile: UserProfileStore
    @ObservedObject var store: CommentsStore

    let postID: UUID
    let onAddComment: () -> Void  

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            List {
                ForEach(store.list(for: postID)) { c in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(c.user)
                                .font(.subheadline.weight(.semibold))
                            Text("• \(c.time)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(c.text)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)

            Divider()

            HStack(spacing: 10) {
                TextField("Write a comment…", text: $text)
                    .textFieldStyle(.roundedBorder)

                Button("Send") {
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }

                    store.addComment(postID: postID, user: profile.displayName, text: trimmed)

                    // ✅ update count in feed item
                    onAddComment()

                    text = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            store.seedIfNeeded(for: postID)
        }
        .presentationDetents([.medium, .large])
    }
}
