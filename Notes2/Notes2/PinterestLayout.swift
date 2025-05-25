//
//  PinterestLayout.swift
//  Notes2
//
//  Created by alex surmava on 28.01.25.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func textForItem(at indexPath: IndexPath) -> String
    func titleForItem(at indexPath: IndexPath) -> String
}

class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate?
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 10
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var appearingIndexPaths: Set<IndexPath> = []
    private var disappearingIndexPaths: Set<IndexPath> = []

    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        cache.removeAll()
        let columnWidth = (contentWidth - CGFloat(numberOfColumns + 1) * cellPadding) / CGFloat(numberOfColumns)
        
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * (columnWidth + cellPadding) + cellPadding)
        }
        
        var yOffset: [CGFloat] = Array(repeating: cellPadding, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let column = yOffset.firstIndex(of: yOffset.min()!) ?? 0
            
            let title = delegate?.titleForItem(at: indexPath) ?? ""
            let titleHeight = estimatedHeightForText(title, width: columnWidth, fontSize: 14)

            let text = delegate?.textForItem(at: indexPath) ?? ""
            let textHeight = estimatedHeightForText(text, width: columnWidth, fontSize: 12)

            let totalHeight = titleHeight + textHeight + (cellPadding * 3)
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: totalHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + totalHeight + cellPadding
        }
    }
    
    private func estimatedHeightForText(_ text: String, width: CGFloat, fontSize: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
        let boundingBox = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return ceil(boundingBox.height) + 10
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = layoutAttributesForItem(at: itemIndexPath) else { return nil }
        if appearingIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0.0
            attributes.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = layoutAttributesForItem(at: itemIndexPath) else { return nil }
        if disappearingIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0.0
            attributes.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        return attributes
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        appearingIndexPaths.removeAll()
        disappearingIndexPaths.removeAll()

        for update in updateItems {
            switch update.updateAction {
            case .insert:
                if let indexPath = update.indexPathAfterUpdate {
                    appearingIndexPaths.insert(indexPath)
                }
            case .delete:
                if let indexPath = update.indexPathBeforeUpdate {
                    disappearingIndexPaths.insert(indexPath)
                }
            default:
                break
            }
        }
    }
}
