//
//  TrackerCategoryCell.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

//import UIKit
//
//final class TrackerCategoryCell: UITableViewCell {
//    static let reuseId = "TrackerCategoryCell"
//
//    // Карточный фон
//    private let cardView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .systemGray6
//        v.layer.cornerRadius = 16
//        v.layer.masksToBounds = true
//        return v
//    }()
//
//    private let titleLabel: UILabel = {
//        let l = UILabel()
//        l.font = .systemFont(ofSize: 17, weight: .regular)
//        l.textColor = .label
//        return l
//    }()
//
//    // Своя галочка внутри карточки
//    private let checkmarkView: UIImageView = {
//        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
//        iv.isHidden = true
//        iv.tintColor = .systemBlue
//        return iv
//    }()
//
//    // Разделитель (если нужно)
//    private let separator: UIView = {
//        let v = UIView()
//        v.backgroundColor = .separator
//        v.isHidden = true
//        return v
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        selectionStyle = .none
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//        accessoryType = .none // ВАЖНО: не используем системный аксессуар
//
//        contentView.addSubview(cardView)
//        [titleLabel, checkmarkView, separator].forEach { cardView.addSubview($0) }
//        [cardView, titleLabel, checkmarkView, separator].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//
//        NSLayoutConstraint.activate([
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//
//            checkmarkView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            checkmarkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//
//            separator.heightAnchor.constraint(equalToConstant: 0.5),
//            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//            separator.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
//        ])
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    // Оставляю твою сигнатуру — ничего не ломаем
//    func configure(title: String, selected: Bool, tint: UIColor) {
//        titleLabel.text = title
//        checkmarkView.isHidden = !selected
//        checkmarkView.tintColor = tint
//    }
//
//    // Если группируешь ячейки в одну «карточку» сверху/снизу:
//    enum Position { case single, first, middle, last }
//    func setPosition(_ position: Position) {
//        if #available(iOS 11.0, *) {
//            switch position {
//            case .single:
//                cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
//                                                .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//            case .first:
//                cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//            case .middle:
//                cardView.layer.maskedCorners = []
//            case .last:
//                cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//            }
//        }
//        separator.isHidden = (position == .last || position == .single)
//    }
//}
//
//


import UIKit

final class TrackerCategoryCell: UITableViewCell {
    static let reuseId = "TrackerCategoryCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17)
        l.textColor = .label
        return l
    }()

    private let checkmarkView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .systemBlue
        iv.isHidden = true
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .none
        backgroundColor = .clear           // ← важно: ячейка прозрачная
        contentView.backgroundColor = .clear

        [titleLabel, checkmarkView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            // высота строки как в макете
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, selected: Bool, tint: UIColor) {
        titleLabel.text = title
        checkmarkView.isHidden = !selected
        checkmarkView.tintColor = tint
    }
}
