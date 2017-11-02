/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

public typealias Rect = CGRect
public typealias Point = CGPoint
public typealias Size = CGSize
public typealias Vector = CGVector
public typealias Metric = CGFloat

#if os(macOS)
import AppKit

public typealias View = NSView
public typealias Color = NSColor
public typealias Image = NSImage
public typealias Screen = NSScreen
public typealias Font = NSFont
public typealias EdgeInsets = NSEdgeInsets

internal typealias ClickGestureRecognizer = NSClickGestureRecognizer
#else
import UIKit

public typealias View = UIView
public typealias Color = UIColor
public typealias Image = UIImage
public typealias Screen = UIScreen
public typealias Font = UIFont
public typealias EdgeInsets = UIEdgeInsets

internal typealias ClickGestureRecognizer = UITapGestureRecognizer
#endif
