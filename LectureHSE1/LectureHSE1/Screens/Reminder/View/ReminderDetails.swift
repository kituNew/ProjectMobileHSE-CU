//
//  ReminderDetails.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit

class ReminderDetails: UIViewController {
    
    var addNewReminder: ((Reminder) -> Void)
    
    
    init(addNewReminder: @escaping ((Reminder) -> Void)) {
        self.addNewReminder = addNewReminder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.addNewReminder = {_ in }
        super.init(coder: coder)
    }
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()

    private let titleContainer = UIView()
    private let descriptionContainer = UIView()
    private let priorityContainer = UIView()
    private let flagContainer = UIView()
    private let deadlineContainer = UIView()

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название задачи *"
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "описание"
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let priorityLabel: UILabel = {
        let l = UILabel()
        l.text = "Приоритет"
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let flagLabel: UILabel = {
        let l = UILabel()
        l.text = "Флаг"
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let flagMarkLabel: UILabel = {
        let l = UILabel()
        l.text = "❗️"
        l.textColor = .systemRed
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let deadlineLabel: UILabel = {
        let l = UILabel()
        l.text = "Выполнить до"
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priorityDotsStack = UIStackView()
    private var priorityDots: [UIView] = []
    private var currentPriority: Priority = .low {
        didSet {
            updatePriorityDotsAppearance()
        }
    }

    private let flagSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemBlue
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let deadlineSwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemBlue
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let deadlineButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("26.02 10:00", for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.backgroundColor = UIColor(white: 0.95, alpha: 1)
        b.layer.cornerRadius = 10
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupContainers()
        setupPriorityDots()
        layout()
    }

    private func setupContainers() {
        [titleContainer, descriptionContainer, priorityContainer, flagContainer, deadlineContainer].forEach {
            $0.backgroundColor = UIColor(white: 0.92, alpha: 1)
            $0.layer.cornerRadius = 10
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleContainer.addSubview(titleTextField)
        descriptionContainer.addSubview(descriptionTextField)

        priorityContainer.addSubview(priorityLabel)
        priorityContainer.addSubview(priorityDotsStack)

        flagContainer.addSubview(flagLabel)
        flagContainer.addSubview(flagMarkLabel)
        flagContainer.addSubview(flagSwitch)

        deadlineContainer.addSubview(deadlineLabel)
        deadlineContainer.addSubview(deadlineSwitch)
        deadlineContainer.addSubview(deadlineButton)
    }

    private func setupPriorityDots() {
        priorityDotsStack.axis = .horizontal
        priorityDotsStack.alignment = .center
        priorityDotsStack.spacing = 8
        priorityDotsStack.translatesAutoresizingMaskIntoConstraints = false

        for i in 0..<3 {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.layer.cornerRadius = 10
            v.clipsToBounds = true
            v.tag = i
            v.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPriorityDot(_:)))
            v.addGestureRecognizer(tap)

            NSLayoutConstraint.activate([
                v.widthAnchor.constraint(equalToConstant: 20),
                v.heightAnchor.constraint(equalToConstant: 20)
            ])
            priorityDotsStack.addArrangedSubview(v)
            priorityDots.append(v)
        }

        updatePriorityDotsAppearance()
    }


    private func layout() {
        view.addSubview(saveButton)

        let stack = UIStackView(arrangedSubviews: [
            titleContainer,
            descriptionContainer,
            priorityContainer,
            flagContainer,
            deadlineContainer
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 8),
            titleTextField.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -8),
            titleTextField.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 12),
            titleTextField.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            descriptionTextField.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 8),
            descriptionTextField.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: -8),
            descriptionTextField.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 12),
            descriptionTextField.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            priorityLabel.leadingAnchor.constraint(equalTo: priorityContainer.leadingAnchor, constant: 12),
            priorityLabel.centerYAnchor.constraint(equalTo: priorityContainer.centerYAnchor),

            priorityDotsStack.trailingAnchor.constraint(equalTo: priorityContainer.trailingAnchor, constant: -12),
            priorityDotsStack.centerYAnchor.constraint(equalTo: priorityContainer.centerYAnchor),

            priorityContainer.heightAnchor.constraint(equalToConstant: 56)
        ])

        NSLayoutConstraint.activate([
            flagLabel.leadingAnchor.constraint(equalTo: flagContainer.leadingAnchor, constant: 12),
            flagLabel.centerYAnchor.constraint(equalTo: flagContainer.centerYAnchor),

            flagMarkLabel.leadingAnchor.constraint(equalTo: flagLabel.trailingAnchor, constant: 4),
            flagMarkLabel.centerYAnchor.constraint(equalTo: flagLabel.centerYAnchor),

            flagSwitch.trailingAnchor.constraint(equalTo: flagContainer.trailingAnchor, constant: -12),
            flagSwitch.centerYAnchor.constraint(equalTo: flagContainer.centerYAnchor),

            flagContainer.heightAnchor.constraint(equalToConstant: 56)
        ])

        NSLayoutConstraint.activate([
            deadlineLabel.leadingAnchor.constraint(equalTo: deadlineContainer.leadingAnchor, constant: 12),
            deadlineLabel.centerYAnchor.constraint(equalTo: deadlineContainer.centerYAnchor),

            deadlineSwitch.trailingAnchor.constraint(equalTo: deadlineContainer.trailingAnchor, constant: -12),
            deadlineSwitch.centerYAnchor.constraint(equalTo: deadlineContainer.centerYAnchor),

            deadlineButton.trailingAnchor.constraint(equalTo: deadlineSwitch.leadingAnchor, constant: -12),
            deadlineButton.centerYAnchor.constraint(equalTo: deadlineContainer.centerYAnchor),

            deadlineContainer.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    @objc func didTapSaveButton() {
        let reminder = Reminder(text: titleTextField.text ?? "",
                                description: descriptionTextField.text ?? "",
                                priority: currentPriority,
                                flag: flagSwitch.isOn,
                                toDate: deadlineSwitch.isOn ? Date() : nil,
                                isDone: false
        )
        addNewReminder(reminder)
        dismiss(animated: true)
    }
    
    private func updatePriorityDotsAppearance() {
        for (index, dot) in priorityDots.enumerated() {
            switch currentPriority {
            case .low:
                dot.backgroundColor = index == 0 ? .systemGreen : .systemGray4
            case .medium:
                dot.backgroundColor = index <= 1 ? .systemYellow : .systemGray4
            case .high:
                dot.backgroundColor = .systemRed
            }
        }
    }

    @objc private func didTapPriorityDot(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        guard let newPriority = Priority(rawValue: index) else { return }
        currentPriority = newPriority
    }
}
