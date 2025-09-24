//
//  TrackerContextPreviewViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/24/25.
//

import UIKit

final class TrackerContextPreviewViewController: UIViewController {
    static let targetSize = CGSize(width: 260, height: 72)

    private let emoji: String
    private let text: String
    private let color: UIColor

    private let container = UIView()
    private let stack = UIStackView()
    private let emojiLabel = UILabel()
    private let textLabel = UILabel()

    init(emoji: String, text: String, color: UIColor) {
        self.emoji = emoji
        self.text = text
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        container.backgroundColor = color
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true

        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 22, weight: .regular)
        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)

        textLabel.text = text
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        textLabel.numberOfLines = 2

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        stack.addArrangedSubview(emojiLabel)
        stack.addArrangedSubview(textLabel)

        container.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // фиксируем размер превью
            view.widthAnchor.constraint(equalToConstant: Self.targetSize.width),
            view.heightAnchor.constraint(equalToConstant: Self.targetSize.height)
        ])

        preferredContentSize = Self.targetSize
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if preferredContentSize != Self.targetSize {
            preferredContentSize = Self.targetSize
        }
    }
}
