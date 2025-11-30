//
//  ReminderViewCell.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit

final class ReminderViewCell: UITableViewCell {

    static let reuseIdentifier = "ReminderCell"

    weak var delegate: ReminderViewCellDelegate?

    private let cardView = UIView()
    private let statusButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let exclamationLabel = UILabel()
    private let difficultyStack = UIStackView()
    private var difficultyDots: [UIView] = []
    
    private var isImportant: Bool = false

    private var internalIsDone = false

    var isDone: Bool {
        get { internalIsDone }
        set { setDone(newValue, animated: false, startCountdown: false) }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        internalIsDone = false
        cardView.alpha = 1
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        dateLabel.attributedText = nil
    }

    func configure(with reminder: Reminder) {
        titleLabel.text = reminder.text
        descriptionLabel.text = reminder.description

        if let date = reminder.toDate {
            let f = DateFormatter()
            f.dateStyle = .short
            f.timeStyle = .short
            dateLabel.isHidden = false
            dateLabel.text = f.string(from: date)
        } else {
            dateLabel.isHidden = true
            dateLabel.text = nil
        }

        updateDifficulty(for: reminder.priority)
        isDone = reminder.isDone
        isImportant = reminder.flag
    }

    func toggleDoneFromUser() {
        let newValue = !internalIsDone
        setDone(newValue, animated: true, startCountdown: true)
        delegate?.reminderCell(self, didChangeDone: newValue)
    }

    private func setDone(_ done: Bool, animated: Bool, startCountdown: Bool) {
        internalIsDone = done
        updateDoneUI(animated: animated)
        if done && startCountdown {
            startRemovalCountdown()
        }
    }

    private func updateDoneUI(animated: Bool) {
        let style = internalIsDone ? NSUnderlineStyle.single.rawValue : 0

        let title = titleLabel.text ?? ""
        let desc  = descriptionLabel.text ?? ""

        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .strikethroughStyle: style
            ]
        )

        descriptionLabel.attributedText = NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel,
                .strikethroughStyle: style
            ]
        )

        let changes = {
            self.cardView.alpha = self.internalIsDone ? 0.5 : 1.0
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }

        updateStatusButton()
    }

    private func updateStatusButton() {
        statusButton.layer.cornerRadius = 12
        statusButton.layer.borderWidth = 2

        if internalIsDone {
            statusButton.backgroundColor = .systemGreen
            statusButton.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            statusButton.backgroundColor = .clear
            statusButton.layer.borderColor = UIColor.systemGray3.cgColor
        }
    }

    private func startRemovalCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.internalIsDone else { return }
            self.delegate?.reminderCellDidRequestRemoval(self)
        }
    }

    private func updateDifficulty(for priority: Priority) {
        for (index, dot) in difficultyDots.enumerated() {
            switch priority {
            case .high:
                dot.backgroundColor = .systemRed
            case .medium:
                dot.backgroundColor = index < 2 ? .systemYellow : .systemGray3
            case .low:
                dot.backgroundColor = index == 0 ? .systemGreen : .systemGray3
            }
        }
    }

    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        statusButton.addTarget(self, action: #selector(didTapStatus), for: .touchUpInside)

        titleLabel.font = .boldSystemFont(ofSize: 18)

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .tertiaryLabel

        exclamationLabel.text = "!"
        exclamationLabel.textColor = .systemRed
        exclamationLabel.font = .boldSystemFont(ofSize: 20)
        exclamationLabel.isHidden = !isImportant

        difficultyStack.axis = .horizontal
        difficultyStack.alignment = .center
        difficultyStack.spacing = 6

        for _ in 0..<3 {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 6
            dot.clipsToBounds = true
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 12),
                dot.heightAnchor.constraint(equalToConstant: 12)
            ])
            difficultyStack.addArrangedSubview(dot)
            difficultyDots.append(dot)
        }

        contentView.addSubview(statusButton)
        contentView.addSubview(cardView)

        [titleLabel, descriptionLabel, dateLabel, exclamationLabel, difficultyStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        statusButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            statusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            statusButton.widthAnchor.constraint(equalToConstant: 24),
            statusButton.heightAnchor.constraint(equalToConstant: 24),

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: exclamationLabel.leadingAnchor, constant: -8),

            exclamationLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            exclamationLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            difficultyStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            difficultyStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            difficultyStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            dateLabel.centerYAnchor.constraint(equalTo: difficultyStack.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func didTapStatus() {
        toggleDoneFromUser()
    }
}
