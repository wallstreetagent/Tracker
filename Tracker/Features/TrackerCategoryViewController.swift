//
//  TrackerCategoryViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func categoryViewController(_ vc: TrackerCategoryViewController, didPick title: String)
}

final class TrackerCategoryViewController: UIViewController {
    weak var delegate: TrackerCategoryViewControllerDelegate?

    private let vm: TrackerCategoryViewModel

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Категория"
        l.font = .systemFont(ofSize: 16)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let table: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        t.rowHeight = 75
        t.layer.cornerRadius = 16
        t.clipsToBounds = true
        t.isScrollEnabled = true
        t.backgroundColor = .clear
        t.separatorStyle = .singleLine
        t.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        t.separatorColor = UIColor(red: 0xAE/255.0, green: 0xAF/255.0, blue: 0xB4/255.0, alpha: 1.0)
        return t
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Добавить категорию", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.setTitleColor(.ypWhiteDay, for: .normal)
        b.backgroundColor = .ypBlackDay
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let emptyView: UIStackView = {
        let iv = UIImageView(image: UIImage(named: "placeholderStar")?.withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .vertical)

        let l = UILabel()
        l.text = "Привычки и события можно\nобъединить по смыслу"
        l.textAlignment = .center
        l.numberOfLines = 0
        l.textColor = .secondaryLabel
        l.font = UIFont(name: "SFProText-Medium", size: 12) ?? .systemFont(ofSize: 12, weight: .medium)

        let st = UIStackView(arrangedSubviews: [iv, l])
        st.axis = .vertical
        st.alignment = .center
        st.spacing = 8
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()

    private let scheduleCellBackground = UIColor(
        red: 0xE6/255.0, green: 0xE8/255.0, blue: 0xEB/255.0, alpha: 0.3
    )

    init(viewModel: TrackerCategoryViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay

        table.dataSource = self
        table.delegate = self

        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        [titleLabel, table, addButton, emptyView].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),

            table.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            table.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        if let iv = emptyView.arrangedSubviews.first {
            iv.widthAnchor.constraint(equalToConstant: 80).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }

        bind()
        vm.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func bind() {
        vm.onDataChanged = { [weak self] in
            guard let self else { return }
            self.table.reloadData()
            let isEmpty = self.vm.numberOfRows() == 0
            self.emptyView.isHidden = !isEmpty
            self.table.isHidden = isEmpty
        }
        vm.onError = { [weak self] msg in
            let a = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(a, animated: true)
        }
        vm.onSelection = { [weak self] title in
            guard let self else { return }
            self.delegate?.categoryViewController(self, didPick: title)
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func addTapped() {
        let vc = CategoryCreateViewController()
        vc.onDone = { [weak self] newTitle in
            self?.vm.addCategory(title: newTitle)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentRenameAlert(for indexPath: IndexPath) {
        let current = vm.title(at: indexPath)
        let ac = UIAlertController(title: "Редактировать категорию", message: nil, preferredStyle: .alert)
        ac.addTextField { tf in
            tf.text = current
            tf.clearButtonMode = .whileEditing
            tf.returnKeyType = .done
        }
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self, weak ac] _ in
            guard
                let self,
                let newTitle = ac?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !newTitle.isEmpty
            else { return }
            self.vm.renameCategory(at: indexPath, to: newTitle)
        }))
        present(ac, animated: true)
    }

    private func presentDeleteConfirm(for indexPath: IndexPath) {
        let title = vm.title(at: indexPath)
        let ac = UIAlertController(title: "Удалить категорию?", message: "«\(title)» точно не нужна?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.vm.deleteCategory(at: indexPath)
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = ac.popoverPresentationController {
            pop.sourceView = table
            pop.sourceRect = table.rectForRow(at: indexPath)
        }
        present(ac, animated: true)
    }
}

extension TrackerCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.selectionStyle = .none

        let title = vm.title(at: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = title
        config.textProperties.font = .systemFont(ofSize: 17)
        cell.contentConfiguration = config

        if #available(iOS 14.0, *) {
            var bg = UIBackgroundConfiguration.listPlainCell()
            bg.backgroundColor = scheduleCellBackground   // #E6E8EB with 30%
            cell.backgroundConfiguration = bg
        } else {
            cell.backgroundColor = scheduleCellBackground
        }

        let blue = UIColor(named: "ypBlue") ?? .systemBlue
        cell.tintColor = blue
        cell.accessoryType = (title == vm.selectedTitle) ? .checkmark : .none

        if indexPath.row == vm.numberOfRows() - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        vm.select(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration {
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.presentRenameAlert(for: indexPath)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: [.destructive]) { _ in
                self.presentDeleteConfirm(for: indexPath)
            }
            return UIMenu(children: [edit, delete])
        }
    }
}
