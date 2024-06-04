//
//  MovieSearchListViewControllerTests.swift
//  EnsembleMoviesInOMDBTests
//
//  Created by Lucas C Barros on 2024-05-01.
//

import XCTest
@testable import EnsembleMoviesInOMDB

final class MovieSearchListViewControllerTests: XCTestCase {

    // MARK: Test config properties
    var sutViewController: MovieSearchListViewController?
    var viewModel: MovieSearchListViewModel!
    var networkManager: NetworkManagerMock!

    // MARK: SetUp & TearDown
    override func setUp() {
        networkManager = NetworkManagerMock()
        viewModel = MovieSearchListViewModel(movies: [],
                                             networkManager: networkManager)
        sutViewController = MovieSearchListViewController(viewModel: viewModel)
    }

    override func tearDown() {
        sutViewController = nil
        viewModel = nil
        networkManager = nil
    }

    // MARK: Tap search button
    func testTapSearchButton() {
        // GIVEN
        let searchString = "batman"
        guard let initialText = sutViewController?.searchTextField.text else {
            XCTFail("SearchField is nil")
            return }
        XCTAssertTrue(initialText.isEmpty, "Field should start empty")
        XCTAssertEqual(sutViewController?.viewModel.movies.count, 0,
                       "Movies list should start empty")

        // WHEN
        sutViewController?.searchTextField.text = searchString
        sutViewController?.tapSearchButton()

        // THEN
        XCTAssertEqual(sutViewController?.viewModel.movies.count, 3,
                       "Movies list should be loaded with the search result")
    }
}
