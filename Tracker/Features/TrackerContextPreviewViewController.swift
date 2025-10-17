//
//  TrackerContextPreviewViewController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/24/25.
//



import UIKit

// MARK: - TrackerContextPreviewViewController

final class TrackerContextPreviewViewController: UIViewController {
    
    // MARK: - Constants
    
    static let targetSize = CGSize(width: 260, height: 72)
    
    // MARK: - Properties
    
    private let emoji: String
    private let text: String
    private let color: UIColor
    
    // MARK: - UI
    
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    
    init(emoji: String, text: String, color: UIColor) {
        self.emoji = emoji
        self.text = text
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        container.backgroundColor = color
        
        emojiLabel.text = emoji
        textLabel.text = text
        
        view.addSubview(container)
        container.addSubview(stack)
        stack.addArrangedSubview(emojiLabel)
        stack.addArrangedSubview(textLabel)
        
        preferredContentSize = Self.targetSize
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            view.widthAnchor.constraint(equalToConstant: Self.targetSize.width),
            view.heightAnchor.constraint(equalToConstant: Self.targetSize.height)
        ])
    }
}
