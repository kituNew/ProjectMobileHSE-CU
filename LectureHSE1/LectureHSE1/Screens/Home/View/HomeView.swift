//
//  HomeView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit


final class HomeView: UIViewController {
    let viewModel: HomeViewModel
    var news: [New] = []
    
    var source: Sourse = .all
    
    private var needsRetryWhenOnline = false
    private var isLoading = false
    
    init(viewModel: HomeViewModel) {
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
    
    private let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let filterControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["ALL", "NYT", "INYT"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let searchField: UITextField = {
        let tf = UITextField()
        tf.text = "business"
        tf.placeholder = "Введите текст…"
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Send"
        config.cornerStyle = .medium
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var topBarStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [filterControl, searchField, sendButton])
        st.axis = .horizontal
        st.spacing = 8
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        observeNetwork()
        sendRequest()
    }
    
    private func loadData(source: Sourse, section: String) {
        spinner.startAnimating()
        tableView.isHidden = true

        Task {
            await viewModel.fetchNews(source: source.rawValue, section: section) { [weak self] result in
                guard let self = self else { return }

                self.spinner.stopAnimating()
                self.tableView.isHidden = false

                switch result {
                case .success(let news):
                    self.news = news ?? []
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Ошибка: \(error)")
                }
            }
        }
    }
    
    func setup() {
        view.backgroundColor = .systemBackground

        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none

        view.addSubview(topBarStack)
        view.addSubview(tableView)
        view.addSubview(spinner)

        tableView.dataSource = self
        tableView.delegate = self

        // !!! зарегистрируй свои ячейки тут
        tableView.register(NewCell.self, forCellReuseIdentifier: NewCell.reuseIdentifier)

        // чтобы текстовое поле расширялось, а сегменты/кнопка держали размер
        filterControl.setContentHuggingPriority(.required, for: .horizontal)
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        searchField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Actions
        filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        sendButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)

        NSLayoutConstraint.activate([
            topBarStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBarStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBarStack.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: topBarStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func filterChanged() {
        switch filterControl.selectedSegmentIndex {
        case 0: source = .nyt
        case 1: source = .inyt
        default: source = .all
        }
    }

    @objc private func sendRequest() {
        let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        loadData(source: source, section: text)

        searchField.resignFirstResponder()
    }
    
    private func observeNetwork() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )
    }

    @objc private func networkChanged(_ note: Notification) {
        guard let isConnected = note.object as? Bool else { return }

        if isConnected, needsRetryWhenOnline, !isLoading {
            needsRetryWhenOnline = false
            sendRequest()
        }
    }
}

extension HomeView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewCell.reuseIdentifier,
            for: indexPath
        ) as? NewCell else {
            return UITableViewCell()
        }

        let item = news[indexPath.row]
        cell.configure(with: item, vm: viewModel)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = news[indexPath.row]
        let detailsVC = NewDetailView(new: item, vm: viewModel)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
