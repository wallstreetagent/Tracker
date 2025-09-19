//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/17/25.
//

import UIKit

final class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageControl = UIPageControl()
    private var pages: [OnboardingContentViewController] = []
    var onFinish: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        let p1 = OnboardingContentViewController(
            imageName: "onboarding1",
            title: "Отслеживайте только то, что хотите",
            showButton: false
        )

        let p2 = OnboardingContentViewController(
            imageName: "onboarding2",
            title: "Даже если это не литры воды и йога",
            showButton: true
        )
        p2.onStart = { [weak self] in self?.finish() }

        pages = [p1, p2]

        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false)

        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        dismiss(animated: true) { [weak self] in self?.onFinish?() }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let vc = viewController as? OnboardingContentViewController,
            let idx = pages.firstIndex(where: { $0 === vc }),
            idx > 0
        else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let vc = viewController as? OnboardingContentViewController,
            let idx = pages.firstIndex(where: { $0 === vc }),
            idx < pages.count - 1
        else { return nil }
        return pages[idx + 1]
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            completed,
            let current = pageVC.viewControllers?.first as? OnboardingContentViewController,
            let idx = pages.firstIndex(where: { $0 === current })
        else { return }
        pageControl.currentPage = idx
    }
}
