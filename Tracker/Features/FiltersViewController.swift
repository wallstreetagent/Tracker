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

    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let options = FilterOption.allCases
    private let current: FilterOption

    init(current: FilterOption) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильтры"
        view.backgroundColor = .systemBackground

        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = options[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = opt.title

        // Галочка только для «настоящих» фильтров (по ТЗ – не для .all и .today)
        if !opt.isReset && opt == current {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemBlue
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picked = options[indexPath.row]
        delegate?.filtersViewController(self, didPick: picked)
        dismiss(animated: true)
    }
}
