//
//  FeedViewModel.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
//
//  FeedViewModel.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//

import SwiftUI
import Combine

@MainActor
final class FeedViewModel: ObservableObject {

    @Published private(set) var items: [FeedImageItem] = []
    @Published private(set) var isLoadingInitial = false
    @Published private(set) var isLoadingMore = false

    private let service: PicsumServiceProtocol
    private let downloads: FeedDownloadsActor
    private let imageRepo: ImageRepository

    private var page: Int = 1
    private let limit: Int = 10
    private let prefetchThreshold: Int = 3
    private var lastLoadMoreTriggerID: UUID?

    init(
        service: PicsumServiceProtocol = PicsumService(),
        downloads: FeedDownloadsActor = FeedDownloadsActor(),
        cache: ImageCacheActor = ImageCacheActor()
    ) {
        self.service = service
        self.downloads = downloads
        self.imageRepo = ImageRepository(cache: cache)
    }

    func loadInitial() {
        cancelAll()
        items.removeAll()
        page = 1
        lastLoadMoreTriggerID = nil
        Task { await fetchPage(page: page, initial: true) }
    }

    func refresh() async { loadInitial() }

    func loadMoreIfNeeded(currentItem item: FeedImageItem) {
        guard !isLoadingInitial, !isLoadingMore else { return }
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }

        let triggerIndex = items.index(
            items.endIndex,
            offsetBy: -prefetchThreshold,
            limitedBy: items.startIndex
        ) ?? items.startIndex

        guard idx >= triggerIndex else { return }
        guard lastLoadMoreTriggerID != item.id else { return }
        lastLoadMoreTriggerID = item.id

        page += 1
        Task { await fetchPage(page: page, initial: false) }
    }

    func cancelAll() {
        Task { [downloads] in await downloads.cancelAll() }
        isLoadingInitial = false
        isLoadingMore = false

        for i in items.indices {
            if case .loading = items[i].status {
                items[i].status = .cancelled
            }
        }
    }

    func retry(_ id: UUID) {
        Task { [weak self] in
            guard let self else { return }
            await downloads.cancelTask(for: id)
            await self.downloadItem(id: id)
        }
    }

    func toggleLike(_ id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].isLiked.toggle()
        items[idx].likeCount += items[idx].isLiked ? 1 : -1
    }

    func setAvatar(for postID: UUID, data: Data?) {
        guard let idx = items.firstIndex(where: { $0.id == postID }) else { return }
        items[idx].avatarImageData = data
    }

    func incrementCommentCount(for postID: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == postID }) else { return }
        items[idx].commentCount += 1
    }

    // MARK: - Paging

    private func fetchPage(page: Int, initial: Bool) async {
        if initial { isLoadingInitial = true } else { isLoadingMore = true }

        do {
            let list = try await service.fetchPage(page: page, limit: limit)

            let newItems = list.map { li in
                FeedImageItem(
                    picsumID: li.id,
                    author: li.author,
                    url: PicsumAPI.imageURL(id: li.id, width: 900, height: 700)
                )
            }

            let startIndex = items.count
            items.append(contentsOf: newItems)

            let ids = items[startIndex..<items.count].map(\.id)

            await withTaskGroup(of: Void.self) { group in
                for id in ids {
                    group.addTask { [weak self] in
                        guard let self else { return }
                        await self.downloadItem(id: id)
                    }
                }
            }

        } catch {
            // rollback page if loadMore failed
            if !initial { self.page = max(1, self.page - 1) }
        }

        isLoadingInitial = false
        isLoadingMore = false
    }

    // MARK: - Per item download

    private func downloadItem(id: UUID) async {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let url = items[index].url

        // cache
        if let cached = await imageRepo.cachedImage(for: url) {
            items[index].image = cached
            items[index].status = .completed
            return
        }

        items[index].status = .loading
        items[index].image = nil

        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let image = try await self.imageRepo.downloadImage(from: url)
                await self.imageRepo.store(image, for: url)

                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == id }) else { return }
                    self.items[idx].image = image
                    self.items[idx].status = .completed
                }
            } catch is CancellationError {
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == id }) else { return }
                    self.items[idx].status = .cancelled
                }
            } catch {
                await MainActor.run {
                    guard let idx = self.items.firstIndex(where: { $0.id == id }) else { return }
                    self.items[idx].status = .failed("Download failed")
                }
            }

            await self.downloads.removeTask(for: id)
        }

        await downloads.setTask(task, for: id)
        _ = await task.result
    }
}
