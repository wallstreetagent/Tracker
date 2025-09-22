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
    private let countLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .none

        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        countLabel.font = .systemFont(ofSize: 13, weight: .regular)
        countLabel.textColor = .secondaryLabel
        chevron.tintColor = .tertiaryLabel

        let vstack = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        vstack.axis = .vertical
        vstack.spacing = 2

        let hstack = UIStackView(arrangedSubviews: [vstack, chevron])
        hstack.alignment = .center
        hstack.spacing = 8

        contentView.addSubview(hstack)
        hstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hstack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            hstack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            hstack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: TrackerCategoryViewItem) {
        titleLabel.text = item.title
        countLabel.text = "\(item.count)".appending(item.count == 1 ? " трекер" : " трекера")
    }
}
