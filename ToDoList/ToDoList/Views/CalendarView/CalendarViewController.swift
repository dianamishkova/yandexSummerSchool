import UIKit
import Combine
import SwiftUI

class CalendarViewController: UIViewController {
    private let fileCache: FileCache
    private var collectionView: UICollectionView?
    private var cancellables = Set<AnyCancellable>()
    let stackView = UIStackView()
    let scrollView = UIScrollView()
    
    init(fileCache: FileCache) {
        self.fileCache = fileCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .primaryBack
        setupCollectionView()
        setupBinders()
        setupFloatingButton()
    }
    
    private struct Constants {
        static let cellIdentifier: String = "schoolCell"
        static let cellHeight: CGFloat = 60
        static let sectionHeaderIdentifier: String = "sectionHeader"
        static let sectionHeight: CGFloat = 50
    }
    
    private func createScrollableDateButtons() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        scrollView.removeFromSuperview()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        guard let deadlines = fileCache.datesList, !deadlines.isEmpty else {
            return
        }

        for (index, deadline) in deadlines.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(deadline, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(.gray, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index

            button.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 70).isActive = true
            button.heightAnchor.constraint(equalToConstant: 70).isActive = true

            stackView.addArrangedSubview(button)
            
            if index == 0 {
                button.backgroundColor = .highlightedButton
                button.layer.borderWidth = 2.0
                button.layer.borderColor = UIColor.buttonBorder.cgColor
            }
        }

        let separator = UIView()
        separator.backgroundColor = .gray
        separator.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)
        self.view.addSubview(scrollView)
        self.view.addSubview(separator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 70),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            separator.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            separator.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        if let firstButton = stackView.arrangedSubviews.first as? UIButton {
            firstButton.sendActions(for: .touchUpInside)
        }
    }

    @objc private func dateButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let indexPath = IndexPath(item: 0, section: index)
        collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        updateDateSelection(for: index)
    }
    
    
    private func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: view.frame.size.width - 32, height: Constants.cellHeight)
        collectionViewLayout.headerReferenceSize = CGSize(width: view.frame.size.width , height: Constants.sectionHeight)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 0
        
        guard let collectionView = collectionView else {
            return
        }
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .primaryBack
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(ToDoItemCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.sectionHeaderIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }

    private func setupBinders() {
        Publishers.Zip(fileCache.$todoItemsList, fileCache.$datesList)
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                let _ = items.0
                let _ = items.1
                self?.collectionView?.reloadData()
                self?.createScrollableDateButtons()
                self?.collectionView?.layoutIfNeeded()
            }
            .store(in: &cancellables)

        
        fileCache.$error
            .receive(on: RunLoop.main)
            .sink { error in
                if let error = error {
                    switch error {
                    case .retrievingError(let errorMessage):
                        print(errorMessage)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupFloatingButton() {
        let floatingButton = UIButton(type: .system)
        let plusIcon = UIImage(systemName: "plus.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 44, weight: .regular, scale: .default))
        floatingButton.setImage(plusIcon, for: .normal)
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        
        self.view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        
    }
        
    @objc private func floatingButtonTapped() {
        let swiftUIView = TaskView(todoItem: TodoItem(text: ""), showDate: false).environmentObject(fileCache)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(hostingController, animated: true)
        } else {
            present(hostingController, animated: true, completion: nil)
        }
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileCache.dateSectionsList?[section].todos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? ToDoItemCell else {
            return UICollectionViewCell()
        }
        cell.fileCache = fileCache
        if let dateSection = fileCache.dateSectionsList?[indexPath.section] {
            let todo = dateSection.todos[indexPath.item]
            cell.populate(todo)
            
            let isFirstItem = indexPath.item == 0
            let isLastItem = indexPath.item == dateSection.todos.count - 1
            
            var corners: UIRectCorner = []
            if isFirstItem {
                corners.insert(.topLeft)
                corners.insert(.topRight)
            }
            if isLastItem {
                corners.insert(.bottomLeft)
                corners.insert(.bottomRight)
            }
            cell.setCornerRadius(corners: corners, radius: 16)

            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fileCache.dateSectionsList?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader,
           let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.sectionHeaderIdentifier, for: indexPath) as? SectionHeaderView {
            sectionHeader.headerLabel.text = fileCache.dateSectionsList?[indexPath.section].date.description
            return sectionHeader
        }
        return UICollectionReusableView()
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else { return }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems.sorted()
        if let firstVisibleIndexPath = visibleIndexPaths.first {
            updateDateSelection(for: firstVisibleIndexPath.section)
        }
    }
    
    private func updateDateSelection(for section: Int) {
        for button in stackView.arrangedSubviews.compactMap({ $0 as? UIButton }) {
            if button.tag == section {
                button.backgroundColor = .highlightedButton
                button.layer.borderWidth = 2.0
                button.layer.borderColor = UIColor.buttonBorder.cgColor
            } else {
                button.setTitleColor(.gray, for: .normal)
                button.backgroundColor = .clear
                button.layer.borderWidth = 0.0
            }
        }
    }
}
