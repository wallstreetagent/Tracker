//
//  ChooseTrackerTypeViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/26/25.
//

import UIKit

protocol ChooseTrackerTypeDelegate: AnyObject {
    func chooseTypeDidPick(_ type: TrackerType)
}

final class ChooseTrackerTypeViewController: UIViewController {
    weak var delegate: ChooseTrackerTypeDelegate?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Создание трекера"
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textAlignment = .center
        return l
    }()

    private static func makeButton(_ title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.contentEdgeInsets = UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
        return b
    }

    private let habitButton = makeButton("Привычка")
    private let eventButton = makeButton("Нерегулярное событие")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [titleLabel, habitButton, eventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        habitButton.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        eventButton.addTarget(self, action: #selector(eventTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),

            eventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            eventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            eventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            eventButton.heightAnchor.constraint(equalTo: habitButton.heightAnchor)
        ])
    }

    @objc private func habitTapped() { delegate?.chooseTypeDidPick(.habit) }
    @objc private func eventTapped() { delegate?.chooseTypeDidPick(.event) }
}
