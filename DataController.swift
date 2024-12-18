//
//  DataController.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/14/24.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    var container: NSPersistentContainer!
    @Published var selectedVideo: Video?
    @Published var videoList: [Video] = []
    private var saveTask: Task<Void, Error>?
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        
        if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }

        }
        fetchVideos()
    }
    
    func fetchVideos() {
        let request = Video.fetchRequest()
        videoList = (try? container.viewContext.fetch(request)) ?? []
    }
    
    func save() {
        saveTask?.cancel()
        fetchVideos()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    static func deleteVideoIfCancelled(videoURL: URL) {
        do {
            try FileManager.default.removeItem(at: videoURL)
        } catch {
            print("Failed to delete video: \(error)")
        }
    }
    
    func saveVideoToCoreData(videoName: String, videoURL: URL, firstImageURL: URL, videoDuration: Double) {
        let viewContext = container.viewContext
        guard !videoName.isEmpty else { return }
        
        let video = Video(context: viewContext)
        video.myVideoID = UUID()
        video.myName = videoName
        video.myVideoURL = videoURL
        video.myThumbnailURL = firstImageURL
        video.length = videoDuration
        
    
        queueSave()
        
    }
    
}
