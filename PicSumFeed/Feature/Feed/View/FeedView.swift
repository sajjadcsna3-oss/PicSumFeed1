//
//  FeedView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
//
//  FeedView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var vm = FeedViewModel()

    @StateObject private var profile = UserProfileStore()
    @StateObject private var commentsStore = CommentsStore()

    @State private var selectedImage: UIImage?
    @State private var selectedTab: Int = 0

    @State private var activeCommentsPostID: UUID?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                topBar
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.items) { item in
                          
                            FeedPostCellView(
                                item: item,
                                onRetry: { vm.retry(item.id) },
                                onLike: { vm.toggleLike(item.id) },
                                onShare: { },
                                onOpenComments: { activeCommentsPostID = item.id },
                                onPickAvatar: { postID, data in
                                    // ✅ Per-post avatar (only that cell changes)
                                    vm.setAvatar(for: postID, data: data)
                                },
                                onOpenImage: {
                                    // ✅ Fullscreen ONLY when image-area tapped
                                    if let img = item.image { selectedImage = img }
                                }
                            )
                            .environmentObject(profile)
                            // ✅ Pagination remains same
                            .onAppear {
                                vm.loadMoreIfNeeded(currentItem: item)
                            }
                        }

                        if vm.isLoadingMore {
                            ProgressView().padding(.vertical, 14)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
                .refreshable { await vm.refresh() }

                bottomTabBar
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: Binding(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            )) {
                if let selectedImage {
                    FullScreenImageView(image: selectedImage)
                }
            }
            .sheet(item: Binding(
                get: { activeCommentsPostID.map { IdentifiedPostID(id: $0) } },
                set: { newValue in activeCommentsPostID = newValue?.id }
            )) { wrapper in
                // NOTE: This relies on CommentsSheetView having onAddComment closure
                CommentsSheetView(
                    store: commentsStore,
                    postID: wrapper.id,
                    onAddComment: {
                        // ✅ Update comment count in feed when user adds comment
                        vm.incrementCommentCount(for: wrapper.id)
                    }
                )
                .environmentObject(profile)
            }
            .onAppear {
                if vm.items.isEmpty { vm.loadInitial() }
            }
            .onDisappear {
                vm.cancelAll()
            }
        }
    }

    // Wrapper for sheet(item:)
    private struct IdentifiedPostID: Identifiable {
        let id: UUID
    }

    // MARK: Top bar (center title + only 3 dots)

    private var topBar: some View {
        HStack {
            Spacer()

            Text("PicSum Feed")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Menu {
                Button {
                    vm.loadInitial()
                } label: {
                    Label("Reload Feed", systemImage: "arrow.clockwise")
                }

                Button(role: .destructive) {
                    vm.cancelAll()
                } label: {
                    Label("Cancel All", systemImage: "xmark.circle")
                }

            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
            }
        }
    }

    // MARK: Bottom Tab Bar (UI only)

    private var bottomTabBar: some View {
        HStack {
            tabItem(icon: "house.fill", title: "Home", index: 0)
            tabItem(icon: "magnifyingglass", title: "Search", index: 1)
            tabItem(icon: "bell", title: "Activity", index: 2)
            tabItem(icon: "person", title: "Profile", index: 3)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabItem(icon: String, title: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(selectedTab == index ? Color.blue : Color.secondary)
            .frame(maxWidth: .infinity)
        }
    }
}
