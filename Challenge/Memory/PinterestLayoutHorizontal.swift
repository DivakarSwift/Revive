//
//  PinterestLayoutHorizontal
//
//  Created by Alessandro Graziani on 13/12/17.
//  Copyright © 2017 Alessandro Graziani. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: class {
  // 1. Method to ask the delegate for the height of the image
  func collectionView(_ collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
  //1. Pinterest Layout Delegate
  weak var delegate: PinterestLayoutDelegate!
  
  //2. Configurable properties
  fileprivate var numberOfRows = 3
  fileprivate var cellPadding: CGFloat = 6
  
  //3. Array to keep a cache of attributes.
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  
  //4. Content height and size
  fileprivate var contentWidth: CGFloat = 0
  
  fileprivate var contentHeight: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.height - (insets.top + insets.bottom)
  }
  
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    
    // 1. Only calculate if needed
    if DataManager.shared.haveToReloadLayout == false {
        return
    }
    // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
    let rowHeight = contentHeight / CGFloat(numberOfRows)
    var yOffset = [CGFloat]()
    for rows in 0 ..< numberOfRows {
      yOffset.append(CGFloat(rows) * rowHeight)
    }
    var row = 0
    var xOffset = [CGFloat](repeating: 0, count: numberOfRows)
    
    // 3. Iterates through the list of items in the first section
    for item in 0 ..< (collectionView?.numberOfItems(inSection: 0))! {
      
      let indexPath = IndexPath(item: item, section: 0)
      
      // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        let photoWidth = delegate.collectionView(collectionView!, widthForPhotoAtIndexPath: indexPath)
      let width = cellPadding * 2 + photoWidth
      let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowHeight)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      
      // 6. Updates the collection view content height
      contentWidth = max(contentWidth, frame.maxX)
      xOffset[row] = xOffset[row] + width
      
      row = row < (numberOfRows - 1) ? (row + 1) : 0
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
  
}
