//
//  NewDetailView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import UIKit

final class NewDetailView: UIViewController {
    private let new: New
    private let imageLoader: LoadNewsImageUseCaseProtocol
    private let router: NewsDetailRouting

    init(
        new: New,
        imageLoader: LoadNewsImageUseCaseProtocol,
        router: NewsDetailRouting
    ) {
        self.new = new
        self.imageLoader = imageLoader
        self.router = router
        super.init(nibName: nil, bundle: nil)
        title = new.section
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.numberOfLines = 0
        return l
    }()

    private let bylineLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let datesLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 0
        return l
    }()

    private let abstractLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .regular)
        l.numberOfLines = 0
        return l
    }()

    private lazy var openButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Открыть"
        config.cornerStyle = .large
        let b = UIButton(configuration: config)
        b.addTarget(self, action: #selector(openTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        fill()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, bylineLabel, datesLabel, abstractLabel, openButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            imageView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func fill() {
        titleLabel.text = new.title
        bylineLabel.text = new.byline
        abstractLabel.text = new.abstract

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short

        datesLabel.text = """
        Updated: \(df.string(from: new.updatedDate))
        Published: \(df.string(from: new.publishedDate))
        """

        Task { [weak self] in
            guard let self else { return }
            let img = await imageLoader.execute(urlString: new.multimedia?.first?.url)
            await MainActor.run {
                self.imageView.image = img ?? UIImage(systemName: "photo")
            }
        }

        openButton.isHidden = (new.url == nil && new.relatedUrls?.first?.url == nil)
    }

    @objc private func openTapped() {
        guard let urlString = new.url ?? new.relatedUrls?.first?.url else { return }
        router.openWeb(urlString: urlString, title: new.title)
    }
}
