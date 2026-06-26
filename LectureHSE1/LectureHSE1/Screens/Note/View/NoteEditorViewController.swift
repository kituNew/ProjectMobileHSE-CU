import UIKit

final class NoteEditorViewController: UIViewController {
    private var note: Note
    private let onSave: (Note) -> Void

    private let titleField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Заголовок"
        return textField
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 17)
        textView.layer.borderColor = UIColor.separator.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return textView
    }()

    init(note: Note?, onSave: @escaping (Note) -> Void) {
        self.note = note ?? Note(title: "", text: "")
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
        title = note == nil ? "Новая заметка" : "Заметка"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        titleField.text = note.title
        textView.text = note.text

        view.addSubview(titleField)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            textView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func saveTapped() {
        note.title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        note.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(note)
        navigationController?.popViewController(animated: true)
    }
}
