//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/29/25.
//

import UIKit

final class EmptyStateView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let stack = UIStackView()

    init(
        image: UIImage? = UIImage(named: "nothing"),
        text: String = "Ничего не найдено"
    ) {
        super.init(frame: .zero)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit

        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = UIColor.systemGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            // чтобы размер эмодзи был как в макете
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
