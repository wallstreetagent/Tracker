//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/1/25.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ vc: FiltersViewController, didPick option: FilterOption)
}

final class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: FiltersViewControllerDelegate?

    private let options = FilterOption.allCases
    private var current: FilterOption

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Фильтры"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    private let table: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = 60
        tv.contentInsetAdjustmentBehavior = .never
        return tv
    }()

    init(current: FilterOption) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        table.dataSource = self
        table.delegate = self
        table.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseId)
        layout()
    }

    private func layout() {
        [titleLabel, table].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            table.heightAnchor.constraint(equalToConstant: CGFloat(options.count) * 60),
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseId, for: indexPath) as! FilterCell
        let opt = options[indexPath.row]

        let rows = tableView.numberOfRows(inSection: indexPath.section)
        let position: FilterCell.GroupPosition = (rows == 1) ? .single
            : (indexPath.row == 0 ? .first
            : (indexPath.row == rows - 1 ? .last : .middle))

        // Если по ТЗ не нужно показывать галочку для .all / .today — просто поменяй условие здесь.
        let checked = (opt == current)

        cell.configure(title: opt.title, checked: checked, position: position)
        return cell
    }

    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picked = options[indexPath.row]
        current = picked
        delegate?.filtersViewController(self, didPick: picked)
        dismiss(animated: true)
    }
}

// MARK: - Карточная ячейка с внутренней галочкой

private final class FilterCell: UITableViewCell {
    static let reuseId = "FilterCell"

    enum GroupPosition { case single, first, middle, last }

    private let cardView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.backgroundColor = .systemBackground
        return v
    }()

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

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        v.isHidden = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView)
        [titleLabel, checkmarkView, separator].forEach { cardView.addSubview($0) }

        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            checkmarkView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkView.isHidden = true
        separator.isHidden = true
    }

    func configure(title: String, checked: Bool, position: GroupPosition) {
        titleLabel.text = title
        checkmarkView.isHidden = !checked

        if #available(iOS 11.0, *) {
            switch position {
            case .single:
                cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .first:
                cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case .middle:
                cardView.layer.maskedCorners = []
            case .last:
                cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }

        separator.isHidden = (position == .last || position == .single)
    }
}
