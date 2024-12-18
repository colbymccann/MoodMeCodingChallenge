//
//  VideoView.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/13/24.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @ObservedObject var video: Video
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Name", text: $video.myName)
                    .font(.title)
                    .padding()
                Spacer()
            }
            Spacer()
            VideoPlayer(player: AVPlayer(url: video.myVideoURL))
        }
    }
    
}
