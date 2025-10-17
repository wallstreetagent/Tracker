//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import UIKit

final class ScheduleViewController: UIViewController {

    var onDone: ((Set<Weekday>) -> Void)?

    // MARK: - State
    private var selected = Set<Weekday>()
    private let weekdaysOrder: [Weekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Расписание"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .ypBlackDay                    // адаптивный цвет текста
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let table: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
        t.rowHeight = 75
        t.layer.cornerRadius = 16
        t.isScrollEnabled = false
        t.clipsToBounds = true
        t.backgroundColor = .clear                   // контейнер делаем прозрачным
        t.separatorStyle = .singleLine
        t.separatorColor = .appSeparator             // адаптивный цвет разделителя
        return t
    }()

    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Готово", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.setTitleColor(.ypWhiteDay, for: .normal)   // белый в обеих темах
        b.backgroundColor = .ypBlackDay              // #1A1B22 в обеих темах (по макету)
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init
    init(initialSelection: Set<Weekday> = []) {
        self.selected = initialSelection
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhiteDay          // фон экрана (Light=white, Dark=#1A1B22)

        table.dataSource = self
        table.delegate = self

        [titleLabel, table, doneButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            table.heightAnchor.constraint(equalToConstant: 525),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Actions
    @objc private func didTapDone() {
        onDone?(selected)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdaysOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let day = weekdaysOrder[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        cell.selectionStyle = .none

        // Текст дня — адаптивный цвет
        var config = cell.defaultContentConfiguration()
        config.text = day.fullName
        config.textProperties.font = .systemFont(ofSize: 17)
        config.textProperties.color = .ypBlackDay
        cell.contentConfiguration = config

        // Фон строки — адаптивный (CardBackground: Light=#F4F5F7, Dark=#25272E)
        cell.backgroundColor = .ypBackground

        // Свитч
        let s: UISwitch
        if let existing = cell.accessoryView as? UISwitch {
            s = existing
        } else {
            s = UISwitch()
            s.addTarget(self, action: #selector(sw(_:)), for: .valueChanged)
            cell.accessoryView = s
        }
        s.onTintColor = .ypBlue
        s.isOn = selected.contains(day)
        s.tag = day.rawValue

        // Последнюю линию-разделитель скрываем
        if indexPath.row == weekdaysOrder.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        return cell
    }

    @objc private func sw(_ sender: UISwitch) {
        guard let d = Weekday(rawValue: sender.tag) else { return }
        if sender.isOn { selected.insert(d) } else { selected.remove(d) }
    }
}
