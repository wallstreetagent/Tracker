//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/17/25.
//

import UIKit

final class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var onFinish: (() -> Void)?

    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pages: [OnboardingContentViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let p1 = OnboardingContentViewController(
            imageName: "onboarding1",
            title: "Отслеживайте только то, что хотите",
            showsButton: true
        )
        let p2 = OnboardingContentViewController(
            imageName: "onboarding2",
            title: "Даже если это не литры воды и йога",
            showsButton: true
        )
        p2.onStart = { [weak self] in self?.finish() }

        pages = [p1, p2]

        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false)

        for (i, p) in pages.enumerated() {
            p.configurePages(total: pages.count, index: i)
        }
    }

    private func finish() {
        OnboardingFlag.isSeen = true
        if presentingViewController != nil { dismiss(animated: true) } else { onFinish?() }
    }

    // MARK: DataSource
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController as! OnboardingContentViewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController as! OnboardingContentViewController), idx < pages.count - 1 else { return nil }
        return pages[idx + 1]
    }
}
