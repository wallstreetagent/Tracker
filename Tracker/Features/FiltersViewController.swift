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

 
    private let table: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .ypBackground
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        tv.separatorStyle = .singleLine
        tv.separatorColor = .separator
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.rowHeight = 60
        tv.tableFooterView = UIView()
        return tv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("filters.title", comment: "")
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    init(current: FilterOption) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay

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
            table.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseId, for: indexPath) as! FilterCell
        let opt = options[indexPath.row]
        let checked = (opt == current) // если нужно скрывать галку у .all/.today — поменяй условие тут
        cell.configure(title: opt.title, checked: checked)
        return cell
    }

    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        current = options[indexPath.row]
        delegate?.filtersViewController(self, didPick: current)
        dismiss(animated: true)
    }
}

// MARK: - Плоская ячейка (фон прозрачный, галочка внутри)
private final class FilterCell: UITableViewCell {
    static let reuseId = "FilterCell"

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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [titleLabel, checkmarkView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        checkmarkView.isHidden = true
    }

    func configure(title: String, checked: Bool) {
        titleLabel.text = title
        checkmarkView.isHidden = !checked
    }
}
