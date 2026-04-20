//
//  ImageCacheActor.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import UIKit

actor ImageCacheActor {
    private var store: [URL: UIImage] = [:]

    func get(_ url: URL) -> UIImage? { store[url] }
    func set(_ image: UIImage, for url: URL) { store[url] = image }
    func clear() { store.removeAll() }
}
