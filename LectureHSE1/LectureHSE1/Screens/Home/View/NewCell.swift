//
//  NewCell.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 05.03.2026.
//

import UIKit

final class NewCell: UITableViewCell {
    static let reuseIdentifier = "NewCell"
    
    private let thumbImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        v.backgroundColor = .secondarySystemBackground
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.numberOfLines = 2
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        return l
    }()

    private let bylineLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .tertiaryLabel
        l.numberOfLines = 1
        return l
    }()

    private let textStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        selectionStyle = .default
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        contentView.addSubview(card)

        card.addSubview(thumbImageView)
        card.addSubview(textStack)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        textStack.addArrangedSubview(bylineLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            thumbImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            thumbImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),
            thumbImageView.widthAnchor.constraint(equalToConstant: 72),
            thumbImageView.heightAnchor.constraint(equalToConstant: 72),

            textStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        bylineLabel.text = nil
    }

    func configure(
        with news: New,
        loadImage: @escaping (String?) async -> UIImage?
    ) {
        titleLabel.text = news.title
        subtitleLabel.text = news.abstract
        bylineLabel.text = news.byline

        Task { [weak self] in
            guard let self else { return }
            let img = await loadImage(news.multimedia?.first?.url)
            await MainActor.run {
                self.thumbImageView.image = img ?? UIImage(systemName: "photo")
            }
        }
    }
}
