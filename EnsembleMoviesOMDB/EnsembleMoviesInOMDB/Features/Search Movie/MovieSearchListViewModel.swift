//
//  MovieSearchListViewModel.swift
//  EnsembleMoviesInOMDB
//
//  Created by Lucas C Barros on 2024-04-30.
//

import UIKit

protocol MovieSearchListDelegate: AnyObject {
    func updateMovieList()
    func alertError(title: String, description: String)
}

protocol MovieSearchListViewModelProtocol {
    var movies: [Movie] { get set }
    var delegate: MovieSearchListDelegate? { get set }

    func fetchMovies(with title: String)
}

// MARK: Business logic for Movie Search View Controller
class MovieSearchListViewModel: MovieSearchListViewModelProtocol {
    // MARK: Properties
    var movies: [Movie]
    var searchedMoviesWithPoster: [Movie] = []
    weak var delegate: MovieSearchListDelegate?
    var networkManager: NetworkManagerProtocol

    // MARK: Init
    init(movies: [Movie] = [],
         delegate: MovieSearchListDelegate? = nil,
         networkManager: NetworkManagerProtocol) {
        self.movies = movies
        self.delegate = delegate
        self.networkManager = networkManager
    }

    // MARK: Methods
    // Fetch all movies containing the text
    func fetchMovies(with title: String) {
        if title.isEmpty {
            delegate?.alertError(title: "Invalid empty search",
                                 description: "Can't search an blank title!")
        } else if title.count < 3 {
            delegate?.alertError(title: "Invalid lacking information",
                                 description: "Need more than 3 characters from the title!")
        }

        networkManager.fetchMovies(withTitle: title, completion: { response in
            switch response {
            case .success(let search):
                self.movies = search.movies
                self.updateTableViewWith(self.movies)

                self.fetchMoviePosters()
//                self.fetchAllMoviePosters()

            case .failure(let error):
                self.updateViewWithError(error)
            }
        })
    }

    // Fetch all movie posters BUT update as response comes
    func fetchMoviePosters() {
        for movie in self.movies {
            networkManager.fetchMoviePoster(imageURL: movie.poster, completion: { response in
                switch response {
                case .success(let imageData):
                    var movieWithPoster = movie
                    movieWithPoster.posterImage = imageData
                    self.movies = self.movies.filter({ $0.imdbID != movie.imdbID })
                    self.movies.append(movieWithPoster)

                    self.updateTableViewWith(self.movies)
                case .failure(let error):
                    self.updateViewWithError(error)
                }
            })
        }
    }

    // Fetch all movie posters BUT update all at once
    func fetchAllMoviePosters() {
        let group = DispatchGroup()
        var errorFetched: FetchError?
        self.searchedMoviesWithPoster = []

        for movie in self.movies {

            group.enter()
            networkManager.fetchMoviePoster(imageURL: movie.poster, completion: { response in
                switch response {
                case .success(let imageData):
                    var movieWithPoster = movie
                    movieWithPoster.posterImage = imageData
                    self.searchedMoviesWithPoster.append(movieWithPoster)
                    group.leave()

                case .failure(let error):
                    errorFetched = error
                    group.leave()
                }
            })
        }

        group.notify(queue: .main) {
            if !self.searchedMoviesWithPoster.isEmpty,
               errorFetched == nil {
                self.movies = self.searchedMoviesWithPoster
                self.updateTableViewWith(self.movies)
            } else {
                self.updateViewWithError(errorFetched ?? FetchError.invalidData)
            }
        }
    }

    func updateTableViewWith(_ movies: [Movie]) {
        self.movies = movies

        // Update views in main thread
        DispatchQueue.main.async {
            self.delegate?.updateMovieList()
        }
    }

    func updateViewWithError(_ error: Error) {
        // Update views in main thread
        DispatchQueue.main.async {
            guard let error = error as? FetchError else {
                self.delegate?.alertError(title: "Ops! Unfortunate error:",
                                          description: error.localizedDescription)
                return
            }
            self.delegate?.alertError(title: "Ops! Unfortunate error:",
                                      description: error.description)
        }
    }
}
