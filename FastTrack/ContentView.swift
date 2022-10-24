

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
    
    enum SearchState {
        case none, searching, success, error
    }
    
    
    @AppStorage("searchText") var searchText = ""
    @State private var audioPlayer: AVPlayer?
    
    @State private var searchState = SearchState.none
    @State private var tracks = [Track]()
    @State private var searchList = [SearchTerm]()
    @State private var selectedSearch: SearchTerm?
    
    var body: some View {
        NavigationView {
            
            List(searchList, selection: $selectedSearch) { search in
                Text(search.terms)
                    .tag(search)
                    .contextMenu {
                        Button("Remove", role: .destructive) {
                            delete(search)
                        }
                    }
            }
            .onDeleteCommand {
                guard let selectedSearch = selectedSearch else { return }
                delete(selectedSearch)
            }
            .frame(minWidth: 150)
            
            
            switch searchState {
            case .none:
                Text("Enter a search term to begin...")
                    .frame(maxHeight: .infinity)
            case .searching:
                ProgressView()
                    .frame(maxHeight: .infinity)
            case .success:
                ScrollView {
                    LazyVGrid(columns: gridItems) {
                        ForEach(tracks) { track in
                            TrackView(track: track, onSelected: play)
                        }
                    }
                    .padding()
                }
            case .error:
                Text("Sorry, something wrong, search failed. Please check your internet connection then try again")
                    .frame(maxHeight: .infinity)
            }
        }
        .searchable(text: $searchText, placement: .sidebar)
        .navigationTitle("Fast Track")
        .frame(minWidth: 480, minHeight: 320)
        .onSubmit (of: .search) {
            startSearch()
        }
        .onChange(of: selectedSearch) { search in
            searchText = search?.terms ?? ""
            startSearch()
        }
    }
    
    func startSearch() {
        searchState = .searching
        Task {
            do {
                try await performSearch()
                searchState = .success
            } catch {
                searchState = .error
            }
        }
    }
    
    func performSearch() async throws {
        guard let searchingText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchingText)&limit=100&entity=song") else { return }
        let (data, _) =  try await URLSession.shared.data(from: url)
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResult.results
        
        let newTerm = SearchTerm(terms: searchText)
        if let existingTerm = searchList.first(where: {term in return term == newTerm}) {
            selectedSearch = existingTerm
        } else {
            searchList.append(newTerm)
            selectedSearch = newTerm
            searchText = ""
        }
        
    }
    
    func delete(_ search: SearchTerm) {
        guard let index = searchList.firstIndex(of: search) else { return }
        searchList.remove(at: index)
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
