//
//  FullScreenImageView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import SwiftUI

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                    Text("Close")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding()
            }
        }
    }
}
