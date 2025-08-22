//
//  TrackerCell.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidToggle(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?

    // Цвет карточки задаём извне (цвет трекера)
    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Маленькая «плашка» под эмодзи как в макете
    private let emojiBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let daysLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Кнопка «плюс / галочка» — круглая 34×34
    private let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 17
        b.layer.masksToBounds = true
        b.layer.borderWidth = 2
        // borderColor выставим в configure, чтобы совпадал с цветом трекера
        b.tintColor = UIColor.systemGreen
        return b
    }()

    // состояние на выбранную дату
    private var isDoneToday = false
    private var accentColor: UIColor = .systemGreen // цвет трекера

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(emojiBadge)
        emojiBadge.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)

        contentView.addSubview(daysLabel)
        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            emojiBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            emojiBadge.widthAnchor.constraint(equalToConstant: 24),
            emojiBadge.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBadge.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBadge.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: emojiBadge.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: emojiBadge.centerYAnchor),

            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 6),
            daysLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),

            actionButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            actionButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        actionButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
    }

    // MARK: - Public configure
    func configure(name: String,
                   emoji: String,
                   color: UIColor,
                   daysText: String,
                   isDoneToday: Bool,
                   canToggle: Bool) {
        titleLabel.text = name
        emojiLabel.text = emoji
        daysLabel.text = daysText
        cardView.backgroundColor = color
        accentColor = color

        self.isDoneToday = isDoneToday
        actionButton.isEnabled = canToggle

        // Состояние кнопки по макету
        updateButtonAppearance()
    }

    private func updateButtonAppearance() {
        if isDoneToday {
            // заполненный кружок цветом трекера, белая галочка
            actionButton.backgroundColor = accentColor
            actionButton.layer.borderColor = UIColor.systemBackground.cgColor
            actionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            actionButton.tintColor = .white
        } else {
            // белый фон, зелёная (цвет трекера) обводка и плюс
            actionButton.backgroundColor = .white
            actionButton.layer.borderColor = accentColor.cgColor
            actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
            actionButton.tintColor = accentColor
        }
        actionButton.alpha = actionButton.isEnabled ? 1.0 : 0.4
    }

    @objc private func toggleTapped() {
        // визуальный отклик сразу
        isDoneToday.toggle()
        updateButtonAppearance()
        delegate?.trackerCellDidToggle(self)
    }
}

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0; Scanner(string: s).scanHexInt64(&v)
        guard s.count == 6 else { return .secondarySystemBackground }
        let r = CGFloat((v & 0xFF0000) >> 16) / 255
        let g = CGFloat((v & 0x00FF00) >> 8) / 255
        let b = CGFloat(v & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
