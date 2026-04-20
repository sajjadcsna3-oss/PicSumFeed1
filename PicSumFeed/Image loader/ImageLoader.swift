//
//  ImageLoader.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import Foundation
import UIKit

struct ImageLoader {

    struct ProgressInfo: Sendable {
        let receivedBytes: Int64
        let expectedBytes: Int64?
        let fraction: Double
    }

    static func downloadImage(
        from url: URL,
        onProgress: (@Sendable (ProgressInfo) async -> Void)? = nil
    ) async throws -> UIImage {

        var request = URLRequest(url: url)
        request.timeoutInterval = 60

        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
        let expected: Int64? = response.expectedContentLength > 0 ? response.expectedContentLength : nil

        var data = Data()
        if let expected, expected <= Int64(Int.max) {
            data.reserveCapacity(Int(expected))
        }

        var received: Int64 = 0
        var lastReportedFraction: Double = -1

        for try await byte in asyncBytes {
            try Task.checkCancellation()
            data.append(byte)
            received += 1

            if let expected {
                let fraction = min(1, Double(received) / Double(expected))
                if fraction - lastReportedFraction >= 0.01 || fraction >= 1 {
                    lastReportedFraction = fraction
                    if let onProgress {
                        await onProgress(.init(
                            receivedBytes: received,
                            expectedBytes: expected,
                            fraction: fraction
                        ))
                    }
                }
            } else {
                if received % 50_000 == 0, let onProgress {
                    await onProgress(.init(
                        receivedBytes: received,
                        expectedBytes: nil,
                        fraction: 0
                    ))
                }
            }
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        if let expected, let onProgress {
            await onProgress(.init(receivedBytes: received, expectedBytes: expected, fraction: 1))
        }

        return image
    }
}
