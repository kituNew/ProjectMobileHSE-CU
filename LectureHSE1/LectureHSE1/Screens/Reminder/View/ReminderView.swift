//  ReminderView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 17.11.2025.
//

import UIKit

final class ReminderView: UIViewController {

    private let presenter: ReminderPresenting

    private var items: [Reminder] = []

    init(presenter: ReminderPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let repository = CoreDataReminderRepository(coreDataStack: CoreDataStack())
        self.presenter = ReminderPresenter(
            fetchRemindersUseCase: FetchRemindersUseCase(repository: repository),
            saveReminderUseCase: SaveReminderUseCase(repository: repository),
            deleteReminderUseCase: DeleteReminderUseCase(repository: repository),
            router: ReminderRouter()
        )
        super.init(coder: coder)
        if let presenter = presenter as? ReminderPresenter {
            presenter.view = self
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    @objc private func didTapButton() {
        presenter.addReminderTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        
        view.backgroundColor = .systemBackground
        
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReminderViewCell.self,
                           forCellReuseIdentifier: ReminderViewCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        presenter.viewDidLoad()
    }
}

extension ReminderView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReminderViewCell.reuseIdentifier,
            for: indexPath
        ) as? ReminderViewCell else {
            return UITableViewCell()
        }

        let reminder = items[indexPath.row]
        cell.delegate = self
        cell.configure(with: reminder)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? ReminderViewCell {
            cell.toggleDoneFromUser()
        }
    }
}

extension ReminderView: ReminderViewCellDelegate {

    func reminderCell(_ cell: ReminderViewCell, didChangeDone isDone: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        items[indexPath.row].isDone = isDone
        presenter.updateReminder(items[indexPath.row])
    }

    func reminderCellDidRequestRemoval(_ cell: ReminderViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let reminder = items[indexPath.row]
        presenter.deleteReminder(id: reminder.id)
    }
}

extension ReminderView: ReminderViewProtocol {

    func showReminders(_ reminders: [Reminder]) {
        items = reminders
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
