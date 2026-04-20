//
//  FeedCellView.swift
//  PicSumFeed
//
//  Created by Mac Mini on 17/04/2026.
//
import SwiftUI
import PhotosUI

struct FeedPostCellView: View {
    let item: FeedImageItem

    let onRetry: () -> Void
    let onLike: () -> Void
    let onShare: () -> Void
    let onOpenComments: () -> Void

    let onPickAvatar: (_ postID: UUID, _ data: Data?) -> Void

    let onOpenImage: () -> Void

    @EnvironmentObject private var profile: UserProfileStore

    @State private var showShare = false
    @State private var pickedAvatarItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {

            header
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 10)

            // ✅ Tap gesture moved HERE (image area only)
            imageArea
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    onOpenImage()
                }

            metaRow
                .padding(.horizontal, 12)
                .padding(.top, 10)

            Divider().padding(.top, 10)

            actionsRow
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [item.url])
        }
     
        .onChange(of: pickedAvatarItem) { _, newValue in
            guard let newValue else { return }
            Task {
                let data = try? await newValue.loadTransferable(type: Data.self)
                await MainActor.run {
                    onPickAvatar(item.id, data)
                }
            }
        }
    }

    // MARK: Header (profile image selectable)

    private var header: some View {
        HStack(spacing: 10) {

            PhotosPicker(selection: $pickedAvatarItem, matching: .images) {
                avatarView
            }

            VStack(alignment: .leading, spacing: 2) {
             
                Text(profile.displayName)
                    .font(.subheadline.weight(.semibold))
                Text("Just now")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .padding(6)
            }
        }
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                // ✅ Use per-post avatarImageData
                if let data = item.avatarImageData,
                   let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue.opacity(0.15))
                        .overlay(
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.blue)
                        )
                }
            }
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 14, height: 14)
                .overlay(
                    Image(systemName: "pencil")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.secondary)
                )
                .offset(x: 2, y: 2)
        }
    }

    // MARK: Image

    private var imageArea: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(Color.gray.opacity(0.12))

            if let uiImage = item.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .overlay(bottomGradient)
            } else {
                placeholder
            }

            statusPill
                .padding(10)
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [Color.clear, Color.black.opacity(0.35)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.gray.opacity(0.65))

            switch item.status {
            case .loading:
                ActivityIndicatorView()
                Text("Loading…")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .failed:
                Text("Failed to load")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Retry", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

            case .cancelled:
                Text("Cancelled")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .idle:
                Text("Ready")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .completed:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusPill: some View {
        Group {
            if shouldShowStatusPill {
                HStack(spacing: 6) {
                    Circle().fill(statusColor).frame(width: 8, height: 8)
                    Text(statusText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.35))
                .clipShape(Capsule())
            }
        }
    }

    private var shouldShowStatusPill: Bool {
        switch item.status {
        case .loading, .failed, .cancelled: return true
        case .idle, .completed: return false
        }
    }

    private var statusColor: Color {
        switch item.status {
        case .completed: return .green
        case .failed: return .red
        case .loading: return .blue
        case .cancelled: return .orange
        case .idle: return .gray
        }
    }

    private var statusText: String {
        switch item.status {
        case .idle: return "Idle"
        case .loading: return "Loading"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    // MARK: Meta + Actions

    private var metaRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.blue)
                Text("\(item.likeCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(item.commentCount) comments")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var actionsRow: some View {
        HStack(spacing: 0) {
            action(icon: item.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup",
                   title: "Like",
                   accent: item.isLiked) {
                withAnimation(.snappy) { onLike() }
            }

            action(icon: "bubble.right", title: "Comment") {
                onOpenComments()
            }

            action(icon: "arrowshape.turn.up.right", title: "Share") {
                showShare = true
                onShare()
            }
        }
    }

    private func action(icon: String, title: String, accent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(accent ? Color.blue : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }
}
