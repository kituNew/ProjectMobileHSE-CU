//  ReminderView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 17.11.2025.
//

import UIKit

final class ReminderView: UIViewController {
    
    let viewModel: ReminderViewModel
    
    var items: [Reminder] = []
    
    init(viewModel: ReminderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ReminderViewModel()
        super.init(coder: coder)
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
        self.present(ReminderDetails(), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = viewModel.loadReminders()
        tableView.reloadData()
        
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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReminderViewCell.reuseIdentifier,
            for: indexPath
        ) as! ReminderViewCell

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
    }

    func reminderCellDidRequestRemoval(_ cell: ReminderViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
