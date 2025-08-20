//
//  ViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class TrackersViewController: UIViewController {

    // По ТЗ хранилища данных
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // 👇 UIDatePicker вместо прежней кнопки даты
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime         // и дата, и время
        picker.preferredDatePickerStyle = .compact   // компактный, как в макете
        picker.locale = Locale(identifier: "ru_RU")
        picker.timeZone = .current
        picker.minuteInterval = 1
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private let placeholderImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "placeholderStar"))
        imageView.tintColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [titleLabel, plusButton, datePicker, searchBar, placeholderImage, placeholderLabel].forEach {
            view.addSubview($0)
        }

        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)

        setupConstraints()
    }

    // MARK: - Actions

    @objc private func dateChanged(_ sender: UIDatePicker) {
        // здесь фильтруй/обновляй контент под выбранную дату+время
        // например: collectionView.reloadData()
        print("Выбрано:", formatted(sender.date))
    }

    @objc private func didTapPlus() {
        // открыть создание трекера
        print("Плюс нажали")
    }

    // MARK: - Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalToConstant: 44),

            // 👇 ставим пикер справа, по центру с плюсом
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: plusButton.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 10),

            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Helpers

    private func formatted(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "d MMM yyyy, HH:mm"
        return df.string(from: date)
    }
}
