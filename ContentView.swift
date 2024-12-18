//
//  ContentView.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/13/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var viewModel: ARFaceViewViewModel
    @State private var videoName = ""
    @State var toggle: Bool = true
    
    let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dataController.videoList) { item in
                            NavigationLink(destination: VideoView(video: item)) {
                                VideoViewPreview(video: item)
                            }
                        }
                    }
                    .padding()
                }
                
                VStack {
                    Spacer()
                    NavigationLink(destination: RecordView( isToggled: $toggle)) {
                        Text("Record")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color.red)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                    }
                    .padding()
                }
            }
            .alert("Enter Video Name", isPresented: $viewModel.showAlert, actions: {
                TextField("Video Name", text: $videoName)
                Button("Save") {
                    dataController.saveVideoToCoreData(videoName: videoName, videoURL: viewModel.videoURL, firstImageURL: viewModel.firstFrameURL, videoDuration: viewModel.videoDuration)
                }
            }, message: {
                Text("Please provide a name for the video.")
            })
        }
    }
}

