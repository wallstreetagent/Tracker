//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import UIKit

final class ScheduleViewController: UIViewController {

    var onDone: ((Set<Weekday>) -> Void)?

    private var selected = Set<Weekday>(Weekday.everyday)
    private let weekdaysOrder: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Расписание"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .label
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    init(initialSelection: Set<Weekday> = Set<Weekday>(Weekday.everyday)) {
        self.selected = initialSelection.isEmpty ? Set<Weekday>(Weekday.everyday) : initialSelection
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.titleView = titleLabel

        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.rowHeight = 60
        table.sectionHeaderHeight = .leastNonzeroMagnitude
        table.sectionFooterHeight = 8
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.dataSource = self
        table.delegate = self

        view.addSubview(table)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -12),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        table.contentInset.bottom = 12
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }

    @objc private func didTapDone() {
        onDone?(selected)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { weekdaysOrder.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = weekdaysOrder[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.text = ru(day)
        let s = UISwitch()
        s.onTintColor = .systemBlue
        s.isOn = selected.contains(day)
        s.tag = day.rawValue
        s.addTarget(self, action: #selector(sw(_:)), for: .valueChanged)
        cell.accessoryView = s
        return cell
    }

    @objc private func sw(_ sender: UISwitch) {
        guard let d = Weekday(rawValue: sender.tag) else { return }
        if sender.isOn { selected.insert(d) } else { selected.remove(d) }
    }

    private func ru(_ d: Weekday) -> String {
        switch d {
        case .mon: return "Понедельник"
        case .tue: return "Вторник"
        case .wed: return "Среда"
        case .thu: return "Четверг"
        case .fri: return "Пятница"
        case .sat: return "Суббота"
        case .sun: return "Воскресенье"
        }
    }
}
