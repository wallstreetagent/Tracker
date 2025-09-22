//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/17/25.
//

import UIKit

final class OnboardingContentViewController: UIViewController {

    // MARK: Inputs
    private let imageName: String
    private let titleText: String
    private let showsButton: Bool
    var onStart: (() -> Void)?

    // MARK: UI
    private let bgImageView = UIImageView()
    private let titleLabel  = UILabel()
    private let pageControl = UIPageControl()
    private let actionButton = UIButton(type: .system)

    // Макетные расстояния (375×812)
    private let titleSideInset: CGFloat = 16   // ← важно
    private let titleToDots: CGFloat = 16      // заголовок над точками
    private let dotsToButton: CGFloat = 24     // точки над кнопкой
    private let buttonSideInset: CGFloat = 20
    private let buttonBottom: CGFloat = 34
    private let buttonHeight: CGFloat = 60

    // MARK: Init
    init(imageName: String, title: String, showsButton: Bool) {
        self.imageName = imageName
        self.titleText = title
        self.showsButton = showsButton
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // BG
        bgImageView.image = UIImage(named: imageName)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImageView)

        // Title (как в макете)
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0          // перенос по ширине 343pt
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Dots
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        // Button
        actionButton.setTitle("Вот это технологии!", for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = .label
        actionButton.layer.cornerRadius = 16
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20)
        actionButton.isHidden = !showsButton
        actionButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)

        // Constraints (строго по макету)
        NSLayoutConstraint.activate([
            // BG
            bgImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Button
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: buttonSideInset),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -buttonSideInset),
            actionButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -buttonBottom),

            // Dots
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -dotsToButton),

            // Title
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleSideInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -titleSideInset),
            titleLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -titleToDots)
        ])
    }

    @objc private func tap() { onStart?() }

    // Вызывай из родителя, чтобы задать точки
    func configurePages(total count: Int, index: Int) {
        pageControl.numberOfPages = count
        pageControl.currentPage = index
    }
}
