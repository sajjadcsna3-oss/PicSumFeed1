//
//  PicsumAPI.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import Foundation

enum PicsumAPI {

    struct ListItem: Decodable, Identifiable, Sendable {
        let id: String
        let author: String
        let width: Int
        let height: Int
        let url: String
        let download_url: String
    }

    static func fetchList(page: Int, limit: Int) async throws -> [ListItem] {
        var components = URLComponents(string: "https://picsum.photos/v2/list")!
        components.queryItems = [
            .init(name: "page", value: String(page)),
            .init(name: "limit", value: String(limit))
        ]

        let url = components.url!
        var req = URLRequest(url: url)
        req.timeoutInterval = 30

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([ListItem].self, from: data)
    }

    /// Stable image URL for showing in feed (resized).
    /// Using /id/{id}/{w}/{h} gives deterministic image per id, perfect for pagination.
    static func imageURL(id: String, width: Int = 900, height: Int = 650) -> URL {
        URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")!
    }
}
