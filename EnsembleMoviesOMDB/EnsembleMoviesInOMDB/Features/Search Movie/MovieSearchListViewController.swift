//
//  MovieSearchListViewController.swift
//  ensembleMoviesInOMDB
//
//  Created by Lucas C Barros on 2024-04-30.
//

import QuickUIKitDevTools
import UIKit

class MovieSearchListViewController: UIViewController {
    // MARK: Views
    let searchTextField = UITextField()
    let searchButton = UIButton()
    let movieTableView = UITableView()

    // MARK: Properties
    var viewModel: MovieSearchListViewModelProtocol
    var shouldSearch: Bool = true
    var withCustomCell: Bool = true
    var timer:Timer?

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
    }

    init(viewModel: MovieSearchListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions
    @objc func executeAction() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(self.tapSearchButton),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc func tapSearchButton() {
        guard let searchText = searchTextField.text else { return }
        viewModel.fetchMovies(with: searchText)
    }

    @objc func didTapCellButton(_ sender: UIButton) {
        print(">>> button does nothing!")
    }
}

// MARK: - TableView Setup
extension MovieSearchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieSearchTableViewCell.identifier,
                                                       for: indexPath) as? MovieSearchTableViewCell else {
            fatalError("The tableView could not dequeue a MovieSearchTableViewCell in ViewController")
        }
        cell.configure(with: viewModel.movies[indexPath.row])
        cell.button.addTarget(self, action: #selector(didTapCellButton), for: .touchUpInside)
        cell.accessibilityLabel = "MovieSearchTableViewCell\(indexPath.row)"
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

// MARK: - Delegate Methods
extension MovieSearchListViewController: MovieSearchListDelegate {
    func updateMovieList() {
        self.movieTableView.reloadData()
    }

    func alertError(title: String, description: String) {
        popAlert(title: title, message: description)
    }
}

// MARK: - Setup UI
extension MovieSearchListViewController: ViewCodable {
    func addHierarchy() {
        self.view.addSubviews([
            searchTextField,
            searchButton,
            movieTableView])
    }

    func addConstraints() {
        addSearchBarConstraints()
        addTableViewConstraints()
    }

    func additionalConfig() {
        additionalSearchBarConfig()
        additionalTableViewConfig()
        self.view.backgroundColor = .systemBackground
    }

    func addAccessibility() {
        movieTableView.accessibilityLabel = "movieTableView"
    }
}

// MARK: - Setup SearchBar UI
extension MovieSearchListViewController {
    func addSearchBarConstraints() {
        searchTextField
            .topToSuperview(toSafeArea: true)
            .leadingToSuperview(25)
            .heightTo(30)

        searchButton
            .leadingToTrailing(of: searchTextField, margin: 15)
            .trailingToSuperview(25)
            .widthTo(100)
            .topToTop(of: searchTextField)
            .heightOf(searchTextField)
    }

    func additionalSearchBarConfig() {
        searchTextField.placeholder = "Search movie by title"
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.backgroundColor = .systemBackground
        searchTextField.textColor = .label
        searchTextField.layer.cornerRadius = 5
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.gray.cgColor

        searchTextField.addTarget(self,
                                  action: #selector(executeAction),
                                  for: .editingChanged)

        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.layer.cornerRadius = 5
        searchButton.addTarget(self, action: #selector(tapSearchButton), for: .touchUpInside)
    }
}

// MARK: - Setup tableView UI
extension MovieSearchListViewController {
    func addTableViewConstraints() {
        movieTableView
            .topToBottom(of: searchTextField, margin: 25)
            .centerHorizontalToSuperView()
            .widthToSuperview(-50)
            .bottomToSuperview()
    }

    func additionalTableViewConfig() {
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieTableView.register(MovieSearchTableViewCell.self,
                                forCellReuseIdentifier: "MovieSearchTableViewCell")
    }
}
