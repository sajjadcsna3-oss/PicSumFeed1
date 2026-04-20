        //
        //  PicsumService.swift
        //  PicSumFeed
        //
        //  Created by Mac Mini on 20/04/2026.
        //
        import Foundation

        protocol PicsumServiceProtocol {
            func fetchPage(page: Int, limit: Int) async throws -> [PicsumAPI.ListItem]
        }

        struct PicsumService: PicsumServiceProtocol {
            func fetchPage(page: Int, limit: Int) async throws -> [PicsumAPI.ListItem] {
                try await PicsumAPI.fetchList(page: page, limit: limit)
            }
        }
