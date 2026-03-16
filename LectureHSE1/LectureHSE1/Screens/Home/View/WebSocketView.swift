//
//  HomeView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit

struct POWER {
    let id: Int
}

final class WebSocketView: UIViewController {
    let viewModel: WebSocketViewModel
    
    init(viewModel: WebSocketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let indexes: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var structs: [POWER] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.connect()
        
        view.backgroundColor = .systemBackground
        
        load(indexes: indexes) { [weak self] n in
            guard let self = self else { return }
            self.structs = n
            self.tableView.reloadData()
        }
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
                
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func load(indexes ids: [Int], completion: @escaping ([POWER]) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "com.example.queue")
        
        var n = Array<POWER?>(repeating: nil, count: ids.count)

        for (i, ind) in ids.enumerated() {
            group.enter()
            queue.asyncAfter(deadline: .now() + Double.random(in: 0.5...2)) {
                n[i] = POWER(id: ind)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(n.compactMap { $0 })
        }
    }
}

extension WebSocketView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CELL",
            for: indexPath
        )
        
        cell.textLabel?.text = String(structs[indexPath.row].id)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? ReminderViewCell {
            cell.toggleDoneFromUser()
        }
    }
}
