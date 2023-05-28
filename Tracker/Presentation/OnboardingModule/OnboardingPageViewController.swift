//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Aleksandr Velikanov on 20.04.2023.
//

import UIKit

protocol OnboardingPageViewControllerCoordinator {
    var onProceed: (() -> Void)? { get set }
}

final class OnboardingPageViewController: UIPageViewController, OnboardingPageViewControllerCoordinator {
    var onProceed: (() -> Void)?
        
    private let pages: [UIViewController] = [
        OnboardingViewController(style: .blue),
        OnboardingViewController(style: .red)
    ]
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = Asset.ypBlack.color
        pageControl.pageIndicatorTintColor = Asset.ypGray.color
        
        return pageControl
    }()
    
    private lazy var proceedButton: BaseButton = {
        let buttonText = NSLocalizedString("onboardingPageViewController.proceedButton", comment: "Onboarding screen proceed button text")
        let button = BaseButton(style: .confirm, text: buttonText)
        button.addTarget(nil, action: #selector(proceedButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let firstPage = pages.first else { return }
        setViewControllers([firstPage], direction: .forward, animated: true)
        dataSource = self
        delegate = self
        addSubviews()
        applyLayout()
    }
}

// MARK: - Private Methods

@objc private extension OnboardingPageViewController {
    func proceedButtonTapped() {
        onProceed?()
    }
}

// MARK: - Page View Controller Data Source

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pages.firstIndex(of: pageViewController)
        guard let index, index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pages.firstIndex(of: viewController)
        guard let index, index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - Page View Controller Delegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - Subviews configure + layout

private extension OnboardingPageViewController {
    func addSubviews() {
        view.addSubview(pageControl)
        view.addSubview(proceedButton)
    }

    func applyLayout() {
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(proceedButton.snp.top).offset(-24)
        }
        proceedButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(84)
        }
    }
}
