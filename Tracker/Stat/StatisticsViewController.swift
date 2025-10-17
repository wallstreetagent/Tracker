//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

protocol StatisticsProviding: AnyObject {
    var onChange: (() -> Void)? { get set }
    func completedTotal() -> Int
}

final class StatisticsViewController: UIViewController {

    private let provider: StatisticsProviding

    init(provider: StatisticsProviding) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Статистика"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emptyImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cry"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isAccessibilityElement = true
        iv.accessibilityLabel = "Пустая статистика"
        return iv
    }()

    private let emptyText: UILabel = {
        let l = UILabel()
        l.text = "Анализировать пока нечего"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let cardsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let completedCard = StatCardView(tint: .systemBlue)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
        provider.onChange = { [weak self] in self?.reload() }
        reload()
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(emptyImageView)
        view.addSubview(emptyText)
        view.addSubview(cardsStack)

        cardsStack.addArrangedSubview(completedCard)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyImageView.widthAnchor.constraint(equalToConstant: 96),
            emptyImageView.heightAnchor.constraint(equalToConstant: 96),

            emptyText.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyText.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            cardsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func reload() {
        let completed = provider.completedTotal()
        if completed == 0 {
            cardsStack.isHidden = true
            emptyImageView.isHidden = false
            emptyText.isHidden = false
        } else {
            completedCard.configure(value: "\(completed)", subtitle: "Трекеров завершено")
            cardsStack.isHidden = false
            emptyImageView.isHidden = true
            emptyText.isHidden = true
        }
    }
}

