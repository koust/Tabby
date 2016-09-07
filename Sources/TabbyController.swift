import UIKit

/**
 The protocol that will inform you when an item of the tab bar is tapped.
 */
public protocol TabbyDelegate {

  func tabbyDidPress(button: UIButton, _ label: UILabel)
}

/**
 TabbyController is the controller that will contain all the other controllers.
 */
public class TabbyController: UIViewController {

  /**
   The actual tab bar that will contain the buttons, indicator, separator, etc.
   */
  public lazy var tabbyBar: TabbyBar = { [unowned self] in
    let tabby = TabbyBar(items: self.items)
    tabby.translatesAutoresizingMaskIntoConstraints = false
    tabby.delegate = self

    return tabby
  }()

  /**
   An array of TabbyBarItems. The initializer contains the following parameters:

   - Parameter controller: The controller that you set as the one that will appear when tapping the view.
   - Parameter image: The image that will appear in the TabbyBarItem.
   */
  public var items: [TabbyBarItem] {
    didSet {
      tabbyBar.items = items
    }
  }

  /**
   The property to set the current tab bar index.
   */
  public var setIndex = 0 {
    didSet {
      tabbyBar.selectedItem = setIndex
    }
  }

  /**
   Weather the tab bar is translucent or not, this will make you to have to care about the offsets in your controller.
   */
  public var translucent: Bool = false {
    didSet {
//      let controller = controllers[tabbyBar.selectedIndex].controller
//      controller.removeFromParentViewController()
//      controller.view.removeFromSuperview()
//
//      addChildViewController(controller)
//      view.insertSubview(controller.view, belowSubview: tabbyBar)
//      tabbyBar.prepareTranslucency(translucent)
//      applyNewConstraints(controller.view)
    }
  }

  /**
   Weather or not it should show the indicator or not to show in which tab the user is in.
   */
  public var showIndicator: Bool = true {
    didSet {
      tabbyBar.indicator.alpha = showIndicator ? 1 : 0
    }
  }

  /**
   Weather or not it should display a separator or a shadow.
   */
  public var showSeparator: Bool = true {
    didSet {
      tabbyBar.separator.alpha = showSeparator ? 1 : 0
      tabbyBar.layer.shadowOpacity = showSeparator ? 0 : 1
    }
  }

  /**
   The delegate that will tell you when a tab bar is tapped.
   */
  public var delegate: TabbyDelegate?

  // MARK: - Initializers

  /**
   Initializer with a touple of controllers and images for it.
   */
  public init(items items: [TabbyBarItem]) {
    self.items = items

    super.init(nibName: nil, bundle: nil)

    view.addSubview(tabbyBar)

    setupConstraints()
  }

  /**
   Initializer.
   */
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  /**
   Did appear.
   */
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    tabbyBar.positionIndicator(setIndex, animate: false)
  }

  // MARK: - Constraints

  func setupConstraints() {
    constraint(tabbyBar, attributes: [.Leading, .Trailing, .Bottom])

    view.addConstraints([
      NSLayoutConstraint(
        item: tabbyBar, attribute: .Height,
        relatedBy: .Equal, toItem: nil,
        attribute: .NotAnAttribute,
        multiplier: 1, constant: Constant.Dimension.height)
      ])
  }

  // MARK: - Helper methods

  func constraint(subview: UIView, attributes: [NSLayoutAttribute]) {
    for attribute in attributes {
      view.addConstraint(NSLayoutConstraint(
        item: subview, attribute: attribute,
        relatedBy: .Equal, toItem: view,
        attribute: attribute, multiplier: 1, constant: 0)
      )
    }
  }

  func applyNewConstraints(subview: UIView) {
    constraint(subview, attributes: [.Leading, .Trailing, .Top])

    view.addConstraints([
      NSLayoutConstraint(
        item: subview, attribute: .Height,
        relatedBy: .Equal, toItem: view,
        attribute: .Height, multiplier: 1,
        constant: translucent ? 0 : -Constant.Dimension.height)
      ])
  }
}

extension TabbyController: TabbyBarDelegate {

  /**
   The delegate method comming from the tab bar.

   - Parameter index: The index that was just tapped.
   */
  public func tabbyButtonDidPress(index: Int) {
    guard index < items.count else { return }

    let controller = items[index].controller

    /// Check if it should do another action rather than removing the view.
    guard !view.subviews.contains(controller.view) else {
      if let navigationController = controller as? UINavigationController {
        navigationController.popViewControllerAnimated(true)
      } else {
        for case let subview as UIScrollView in controller.view.subviews {
          subview.setContentOffset(CGPointZero, animated: true)
        }
      }

      return
    }

    items.forEach {
      $0.controller.removeFromParentViewController()
      $0.controller.view.removeFromSuperview()
    }

    controller.view.translatesAutoresizingMaskIntoConstraints = false

    addChildViewController(controller)
    view.insertSubview(controller.view, belowSubview: tabbyBar)

    applyNewConstraints(controller.view)
  }
}
