//
//  Video-Helpers.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/14/24.
//

import Foundation

extension Video {
    
    var myName: String {
        get { name ?? "" }
        set { name = newValue}
    }
    
    var myVideoURL: URL {
        get { videoURL ?? URL(fileURLWithPath: "")}
        set { videoURL = newValue}
    }
    
    var myThumbnailURL: URL {
        get { thumbnailURL ?? URL(fileURLWithPath: "")}
        set { thumbnailURL = newValue}
    }
    
    var myVideoID: UUID {
        get { videoID ?? UUID.init()}
        set { videoID = newValue}
    }
}
