//
//  UILayoutGuide+Constraints.swift
//
//  Created by Vladimir Kazantsev
//  Copyright (c) 2018. All rights reserved.
//

import UIKit

@available ( iOS 10, tvOS 10, * )
public extension UIView {
	
	/// Создаёт направляющую для фокуса, добавляет её в окно `superview` текущего объекта,
	/// и цепляет направляющую к краям этого окна по горизонтали,
	/// и по границам текущего объекта по вертикали.
	/// Достаточно часто требуется для того, чтобы фокус переходил на объект,
	/// расположенный не непосредственно над или под текущим объектом с фокусом.
	@discardableResult
	public func setHorizontalFocusGuide( superview: UIView? = nil, insets: UIEdgeInsets = .zero ) -> UIFocusGuide {
		return UIFocusGuide().then {
			( superview ?? self.superview )?.addLayoutGuide( $0 )
			$0.constrainToSuperviewHorizontallyAndVertically( to: self, insets: insets )
			$0.preferredFocusEnvironments = [ self ]
		}
	}
}



public extension UILayoutGuide {

	/// Цепляет гайд к краям родителя по горизонтали, и по границам указанного
	/// окна по вертикали. Достаточно часто требуется на для того, чтобы
	/// фокус переходил на объект, расположенный не непосредственно над или под
	/// текущим объектом с фокусом.
	@discardableResult
	func constrainToSuperviewHorizontallyAndVertically( to view: UIView, insets: UIEdgeInsets = .zero ) -> [ NSLayoutConstraint ] {
		return alignVertically( to: view, insets: insets ) + alignHorizontally( to: owningView!, insets: insets )
	}
}


/// Debug helper extension to visualize UILayoutGuide on screen.
public extension UILayoutGuide {
	
	/// Reveals position of layout guide on screen by inserting
	/// view with specific background color at guides position.
	func reveal( color: UIColor = UIColor.red.withAlphaComponent( 0.2 )) {
		
		guard owningView != nil else {
			print( "Attempt to reveal layout guide without owner view." )
			return
		}
		
		LayoutGuideRevealView.reveal( with: self, color: color )
	}
	
	class LayoutGuideRevealView: UIView {
		static func reveal( with layoutGuide: UILayoutGuide, color: UIColor ) {
			if let revealView =
				LayoutGuideRevealView( layoutGuide: layoutGuide, color: color ) {
				
				objc_setAssociatedObject(
					layoutGuide,
					&LayoutGuideRevealView.AssociatedObjectHandle,
					revealView,
					objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC )
			}
		}
		
		private init?( layoutGuide: UILayoutGuide, color: UIColor ) {
			
			guard let owningView = layoutGuide.owningView else { return nil }
			
			if let existingView = objc_getAssociatedObject( layoutGuide, &LayoutGuideRevealView.AssociatedObjectHandle ) as? UIView {
				existingView.removeFromSuperview()
			}
			
			super.init( frame: .zero )
			
			translatesAutoresizingMaskIntoConstraints = false
			isUserInteractionEnabled = false
			backgroundColor = color
			owningView.addSubview( self )
			layoutGuide.equalSizeWithView( self )
			layoutGuide.centerWithView( self )
			
			observer = layoutGuide.observe( \.owningView ) { [unowned self] guide, change in
				print( change )
				
				guard guide.owningView != self.superview else { return }
				
				// Владеющий этим окном `UILayoutGuide` сменил
				// своё окно. Значит нам надо удалиться.
				// Если `UILayoutGuide` нужно показать своё
				// местоположение, она должна снова вызвать `reveal`.
				self.removeFromSuperview()
				objc_setAssociatedObject(
					guide,
					&LayoutGuideRevealView.AssociatedObjectHandle,
					nil,
					objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC )
			}
		}
		required public init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private var observer: NSKeyValueObservation!
		static private var AssociatedObjectHandle: UInt8 = 0
	}
	
	static var t: NSKeyValueObservation?
}
