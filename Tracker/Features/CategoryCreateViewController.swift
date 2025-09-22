//
//  CategoryCreateViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import UIKit

final class CategoryCreateViewController: UIViewController {
    var onDone: ((String) -> Void)?

    private let tf = UITextField()
    private let doneButton = UIButton(type: .system)
    private var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая категория"
        view.backgroundColor = .systemBackground

        let bg = UIView()
        bg.backgroundColor = .secondarySystemBackground
        bg.layer.cornerRadius = 10

        tf.placeholder = "Введите название категории"
        tf.font = .systemFont(ofSize: 17)
        tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        bg.translatesAutoresizingMaskIntoConstraints = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bg); bg.addSubview(tf)

        NSLayoutConstraint.activate([
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bg.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            bg.heightAnchor.constraint(equalToConstant: 60),

            tf.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 12),
            tf.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -12),
            tf.centerYAnchor.constraint(equalTo: bg.centerYAnchor)
        ])

        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.backgroundColor = .label
        doneButton.setTitleColor(.systemBackground, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.isEnabled = false
        doneButton.alpha = 0.4

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)

        bottomConstraint = doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomConstraint!
        ])

        // клавиатура
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        tf.becomeFirstResponder()
    }

    @objc private func textChanged() {
        let ok = !(tf.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        doneButton.isEnabled = ok
        doneButton.alpha = ok ? 1.0 : 0.4
    }

    @objc private func doneTapped() {
        guard let t = tf.text?.trimmingCharacters(in: .whitespaces), !t.isEmpty else { return }
        onDone?(t)
        navigationController?.popViewController(animated: true)
    }

    @objc private func kbWillChange(_ n: Notification) {
        guard
            let info = n.userInfo,
            let frameEnd = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        let kbVisible = frameEnd.origin.y < UIScreen.main.bounds.height
        bottomConstraint?.constant = kbVisible ? -(frameEnd.height + 8 - view.safeAreaInsets.bottom) : -12
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}
