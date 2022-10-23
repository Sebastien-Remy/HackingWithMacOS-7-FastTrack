

//
//  ContentView.swift
//  FastTrack
//
//  Created by Sebastien REMY on 23/10/2022.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200)),
    ]
    
    @AppStorage("searchText") var searchText = ""
    @State private var audioPlayer: AVPlayer?
    
    
    @State private var tracks = [Track]()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search for a song", text: $searchText)
                    .onSubmit(startSearch)
                Button("Search", action: startSearch)
            }
            
            ScrollView {
                LazyVGrid(columns: gridItems) {
                    ForEach(tracks) { track in
                        TrackView(track: track, onSelected: play)
                    }
                }
            }
        }
    }
    
    func startSearch() {
        Task {
            try await performSearch()
        }
    }
    
    func performSearch() async throws {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&limit=100&entity=song") else { return }
        let (data, _) =  try await URLSession.shared.data(from: url)
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResult.results
        
    }
    
    func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
