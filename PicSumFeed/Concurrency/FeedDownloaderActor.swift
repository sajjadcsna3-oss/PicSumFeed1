//
//  FeedDownloaderActor.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import Foundation

actor FeedDownloadsActor {
    private var tasks: [UUID: Task<Void, Never>] = [:]

    func setTask(_ task: Task<Void, Never>, for id: UUID) {
        tasks[id] = task
    }

    func removeTask(for id: UUID) {
        tasks[id] = nil
    }

    func cancelTask(for id: UUID) {
        tasks[id]?.cancel()
        tasks[id] = nil
    }

    func cancelAll() {
        for (_, t) in tasks { t.cancel() }
        tasks.removeAll()
    }
}
