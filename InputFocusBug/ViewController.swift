import Combine
//import DeclarativeUIKit
//import FilibabaKit
import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
  }

  private lazy var inputField: InputFieldView = {
    InputFieldView { text in
      print(text)
      return true
    }
  }()

  override var inputAccessoryView: UIView? {
    inputField
  }

  override var canBecomeFirstResponder: Bool { true }

  @objc func addItem() {
    inputField.setIsActive(!inputField.isActive.value)
  }

}

public final class InputFieldView: UIView {

  /// Return true if the input field should resign first responder
  private var didAddCallback: (String) -> Bool

  private var propertyAnimator = UIViewPropertyAnimator()

  public init(didAddCallback: @escaping (String) -> Bool) {
    self.didAddCallback = didAddCallback
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    alpha = 0
    insetsLayoutMarginsFromSafeArea = false

    backgroundColor = .magenta
    addSubview(textField)
    NSLayoutConstraint.activate([
      heightAnchor.constraint(equalToConstant: 60),
      textField.leadingAnchor.constraint(equalTo: leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: trailingAnchor),
      textField.topAnchor.constraint(equalTo: topAnchor),
      textField.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  public override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 60)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    textField.layer.cornerRadius = textField.frame.height / 2
  }

  public func setIsActive(_ isActive: Bool, animated: Bool = true) {
    propertyAnimator.stopAnimation(true)
    let duration: TimeInterval = animated ? 0.25 : 0
    propertyAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
      self.alpha = isActive ? 1 : 0
      self.transform = isActive ? .identity : CGAffineTransform(translationX: 0, y: 16)
    }

    propertyAnimator.startAnimation()

    if isActive {
      print("Wanna be first responder")
      self.textField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    self.isActive.send(isActive)
  }

  public var isActive = CurrentValueSubject<Bool, Never>(false)

  public override var canBecomeFirstResponder: Bool { true }

  private lazy var textField: TextField = {
    let textField = TextField()
    textField.edgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
    textField.placeholder = "Add Item"
    textField.backgroundColor = .systemBackground
    textField.layer.shadowRadius = 1.25
    textField.layer.shadowOffset = CGSize(width: 0, height: 0.75)
    textField.layer.shadowColor = UIColor.black.cgColor
    textField.layer.shadowOpacity = 0.24
    textField.returnKeyType = .done
    textField.delegate = self
    textField.tintColor = .label
    textField.autocorrectionType = .no
    textField.textContentType = .oneTimeCode
    textField.font = UIFont.systemFont(ofSize: 20)
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()

}

extension InputFieldView: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if didAddCallback(textField.text ?? "") {
      setIsActive(false)
    }
    textField.text = nil
    return false
  }

  public func textFieldDidBeginEditing(_ textField: UITextField) {
    print("⌨️ Did begin editing")
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    print("⌨️ Did END editing")
    setIsActive(false, animated: true)
  }
}

public final class TextField: UITextField {

  public var edgeInsets: UIEdgeInsets = .zero
  public var clearButtonInset: CGFloat = 0

  public override func textRect(forBounds bounds: CGRect) -> CGRect {
    bounds.inset(by: edgeInsets)
  }

  public override func editingRect(forBounds bounds: CGRect) -> CGRect {
    bounds.inset(by: edgeInsets)
  }

  public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    super.clearButtonRect(forBounds: bounds)
      .insetBy(dx: clearButtonInset, dy: clearButtonInset)
  }

}
