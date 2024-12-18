//
//  VideoViewPreview.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/13/24.
//

import SwiftUI

struct VideoViewPreview: View {
    @ObservedObject var video: Video
    
    var body: some View {
            ZStack(alignment: .bottom) {
                AsyncImage(url: video.myThumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .clipped()
                

                HStack {
                    Text(video.myName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(formattedTime(video.length))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
            }
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.5), radius: 5, x: 2, y: 2)
        }
        
        private func formattedTime(_ seconds: Double) -> String {
            let totalSeconds = Int(seconds)
            let minutes = totalSeconds / 60
            let remainingSeconds = totalSeconds % 60
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
}
