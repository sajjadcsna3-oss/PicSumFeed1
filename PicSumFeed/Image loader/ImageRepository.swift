//
//  ImageRepository.swift
//  PicSumFeed
//
//  Created by Mac Mini on 20/04/2026.
//
import UIKit

struct ImageRepository {
    let cache: ImageCacheActor

    func cachedImage(for url: URL) async -> UIImage? {
        await cache.get(url)
    }

    func downloadImage(
        from url: URL,
        onProgress: (@Sendable (ImageLoader.ProgressInfo) async -> Void)? = nil
    ) async throws -> UIImage {
        try await ImageLoader.downloadImage(from: url, onProgress: onProgress)
    }

    func store(_ image: UIImage, for url: URL) async {
        await cache.set(image, for: url)
    }
}
