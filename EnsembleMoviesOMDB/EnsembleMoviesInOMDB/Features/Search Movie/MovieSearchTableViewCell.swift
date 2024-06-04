//
//  MovieSearchTableViewCell.swift
//  EnsembleMoviesInOMDB
//
//  Created by Lucas C Barros on 2024-05-01.
//

import UIKit
import QuickUIKitDevTools

class MovieSearchTableViewCell: UITableViewCell {
    // MARK: Views
    private let movieTitleLabel = UILabel()
    private let movieReleaseDateLabel = UILabel()
    private let moviePosterImage = UIImageView()
    let button = UIButton()

    // MARK: Properties
    static let identifier = "MovieSearchTableViewCell"

    // MARK: Life Cycle
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    // MARK: Methods
    public func configure(with movie: Movie) {
        movieTitleLabel.text = movie.title
        movieReleaseDateLabel.text = movie.released

        guard let imageData = movie.posterImage else { return }
        moviePosterImage.image = UIImage(data: imageData)
    }
}

// MARK: - Setup UI
extension MovieSearchTableViewCell: ViewCodable {
    func addHierarchy() {
        contentView.addSubviews([movieTitleLabel,
                          movieReleaseDateLabel,
                          moviePosterImage,
                          button])
    }

    func addConstraints() {
        movieReleaseDateLabel
            .topToBottom(of: movieTitleLabel)
            .leadingToLeading(of: movieTitleLabel)
            .heightTo(20)
            .bottomToSuperview()

        movieTitleLabel
            .leadingToTrailing(of: moviePosterImage, margin: 5)
            .trailingToLeading(of: button, margin: 5)
            .topToSuperview()
            .heightTo(30)

        moviePosterImage
            .leadingToSuperview()
            .topToSuperview()
            .bottomToSuperview()
            .widthTo(50)

        button
            .trailingToSuperview()
            .topToSuperview(10)
            .bottomToSuperview(10)
            .widthTo(30)
    }

    func additionalConfig() {
        movieTitleLabel.text = "Placeholder Title"
        movieTitleLabel.font = .boldSystemFont(ofSize: 24)

        movieReleaseDateLabel.text = "Release Date"
        movieReleaseDateLabel.font = .systemFont(ofSize: 16, weight: .light)

        moviePosterImage.image = UIImage(systemName: "questionmark.square.dashed")

        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
    }
}
