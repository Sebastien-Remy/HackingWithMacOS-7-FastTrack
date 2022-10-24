//
//  Track.swift
//  FastTrack
//
//  Created by Sebastien REMY on 23/10/2022.
//

import Foundation

struct Track: Identifiable, Decodable {
    let trackId: Int
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String

    var id: Int { trackId }
    var artworkURL: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
    
}

struct SearchResult: Decodable {
    let results: [Track]
}

struct SearchTerm: Identifiable, Hashable {
    let id = UUID()
    let terms: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchTerm, rhs: SearchTerm) -> Bool {
        return lhs.terms == rhs.terms
    }
}

