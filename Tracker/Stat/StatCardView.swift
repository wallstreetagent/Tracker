//
//  StatCardView.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import UIKit

final class StatCardView: UIView {
    private let valueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .label
        l.setContentHuggingPriority(.required, for: .vertical)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    init(tint: UIColor) {
        super.init(frame: .zero)
        container.layer.borderColor = tint.cgColor
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        container.addSubview(valueLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 96),

            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),

            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }

    func configure(value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }
}
