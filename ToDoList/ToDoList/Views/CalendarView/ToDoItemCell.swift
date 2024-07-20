import FileCachePackage
import Foundation
import UIKit

class ToDoItemCell: UICollectionViewCell {
    private var todoItem: TodoItem?
    var viewModel: ViewModel?
    private var swipeGestureRecognizerRight: UISwipeGestureRecognizer?
    private var swipeGestureRecognizerLeft: UISwipeGestureRecognizer?
    
    private struct Constants {
        static let leftInset: CGFloat = 20
        static let topInset: CGFloat = 10
        static let rightInset: CGFloat = 20
        static let bottomInset: CGFloat = 10
        static let borderWidth: CGFloat = 0.5
        static let cornerRadius: CGFloat = 10.0
    }
    
    private var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private var wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSwipeGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupSwipeGestureRecognizers()
    }
    
    private func setupViews() {
        contentView.backgroundColor = UIColor.secondaryBack
        contentView.addSubview(wrapperView)
        wrapperView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topInset),
            wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomInset),
            wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leftInset),
            wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.rightInset),
            
            textLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: Constants.topInset),
            textLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: Constants.leftInset),
            textLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -Constants.rightInset),
            textLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -Constants.bottomInset),
        ])
    }
    
    func populate(_ todoItem: TodoItem) {
        self.todoItem = todoItem
        updateTextLabel()
    }
    
    private func updateTextLabel() {
        guard let todoItem else { return }
        let text = todoItem.text
        if todoItem.done {
            let attributeString = getAttributedString(text)
            textLabel.attributedText = attributeString
            textLabel.textColor = .gray
        } else {
            textLabel.attributedText = nil
            textLabel.textColor = .primaryL
            textLabel.text = text
        }
    }
    
    func setCornerRadius(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: contentView.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        contentView.layer.mask = mask
    }
    
    private func setupSwipeGestureRecognizers() {
        swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipeGesture))
        swipeGestureRecognizerRight?.direction = .right
        if let swipeGestureRecognizerRight {
            contentView.addGestureRecognizer(swipeGestureRecognizerRight)
        }
        
        swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipeGesture))
        swipeGestureRecognizerLeft?.direction = .left
        if let swipeGestureRecognizerLeft {
            contentView.addGestureRecognizer(swipeGestureRecognizerLeft)
        }
    }
    
    @objc 
    private func handleRightSwipeGesture() {
        todoItem?.done = true
        guard let todoItem else { return }
        viewModel?.updateToDoItem(todoItem)
        updateTextLabel()
    }

    @objc 
    private func handleLeftSwipeGesture() {
        todoItem?.done = false
        guard let todoItem else { return }
        viewModel?.updateToDoItem(todoItem)
        updateTextLabel()
    }
    
    private func getAttributedString(_ text: String) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributeString.length)
        )
        return attributeString
    }
}
