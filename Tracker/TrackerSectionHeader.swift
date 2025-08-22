//
//  TrackerSectionHeader.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/20/25.
//

import UIKit

final class TrackerSectionHeader: UICollectionReusableView {
    static let reuseId = "TrackerSectionHeader"
    private let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .boldSystemFont(ofSize: 19)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setTitle(_ t: String) { titleLabel.text = t }
}
