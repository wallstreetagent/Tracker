//
//  TrackerCategoryCell.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import UIKit

final class TrackerCategoryCell: UITableViewCell {
    static let reuseId = "TrackerCategoryCell"

    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        accessoryType = .none       
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .label

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, selected: Bool, tint: UIColor) {
        titleLabel.text = title
        accessoryType = selected ? .checkmark : .none
        self.tintColor = tint
    }
}
