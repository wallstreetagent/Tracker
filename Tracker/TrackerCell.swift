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

    // MARK: UI

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let emojiBadge: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17)
    
        l.backgroundColor = UIColor.white.withAlphaComponent(0.30)
        l.layer.cornerRadius = 14
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    private let daysLabel: UILabel = {
        let l = UILabel()
        l.textColor = .fromHex("#1A1B22")
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let toggleButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 17
        b.layer.borderWidth = 2
        b.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            b.widthAnchor.constraint(equalToConstant: 34),
            b.heightAnchor.constraint(equalToConstant: 34)
        ])
        return b
    }()

    // MARK: State

    private var isDoneToday = false
    private var canToggle = true
    private var accentColor: UIColor = UIColor(red: 0x33/255, green: 0xCF/255, blue: 0x69/255, alpha: 1)

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)

        contentView.addSubview(cardView)
        cardView.addSubview(emojiBadge)
        cardView.addSubview(nameLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(toggleButton)

        toggleButton.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)

        NSLayoutConstraint.activate([
         
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

        
            emojiBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emojiBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            emojiBadge.widthAnchor.constraint(equalToConstant: 28),
            emojiBadge.heightAnchor.constraint(equalToConstant: 28),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

       
            daysLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            toggleButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        emojiBadge.text = nil
        daysLabel.text = nil
        isDoneToday = false
        canToggle = true
        accentColor = UIColor(red: 0x33/255, green: 0xCF/255, blue: 0x69/255, alpha: 1)
        updateToggleStyle()
    }

    // MARK: Public API

    func configure(name: String,
                   emoji: String,
                   color: UIColor,
                   daysText: String,
                   isDoneToday: Bool,
                   canToggle: Bool) {
        nameLabel.text = name
        emojiBadge.text = emoji
        daysLabel.text = daysText
        cardView.backgroundColor = color
        accentColor = color
        self.isDoneToday = isDoneToday
        self.canToggle = canToggle
        updateToggleStyle()
    }

    func setDoneToday(_ done: Bool) {
        isDoneToday = done
        updateToggleStyle()
    }

    // MARK: Actions & styling

    @objc private func didTapToggle() {
        guard canToggle else { return }
        delegate?.trackerCellDidToggle(self)
    }

    private func updateToggleStyle() {
        toggleButton.layer.cornerRadius = 17
        toggleButton.layer.masksToBounds = true
        toggleButton.layer.borderWidth = 0
        
        if isDoneToday {
        
            toggleButton.backgroundColor = accentColor.withAlphaComponent(0.5)
            toggleButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        } else {
   
            toggleButton.backgroundColor = accentColor
            toggleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        toggleButton.tintColor = .white
        
        toggleButton.isEnabled = canToggle
        toggleButton.alpha = canToggle ? 1.0 : 0.4
    }
}
