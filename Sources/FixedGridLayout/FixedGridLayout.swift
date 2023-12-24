import SwiftUI

public struct FixedVGrid: Layout {
    public var columnWidths: [CGFloat]
    public let spacing: CGFloat
    // public let itemAnchor: UnitPoint

    public init(columnWidths: [CGFloat], spacing: CGFloat = .zero, itemAnchor: UnitPoint = .center) {
        self.columnWidths = columnWidths
        self.spacing = spacing
    }

    public init(count: Int, width: CGFloat, spacing: CGFloat = .zero, itemAnchor: UnitPoint = .center) {
        self.columnWidths = Array(repeating: width, count: count)
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var heights: [CGFloat] = Array(repeating: .zero, count: columnWidths.count)
        for (index, subview) in subviews.enumerated() {
            let columnIndex = index % columnWidths.count
            let size = subview.sizeThatFits(proposal)
            heights[columnIndex] += size.height
        }
        let size = CGSize(width: columnWidths.reduce(0, +), height: heights.max() ?? .zero)
        return size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentHeights: [CGFloat] = Array(repeating: .zero, count: columnWidths.count)

        for (index, subview) in subviews.enumerated() {
            let columnIndex = index % columnWidths.count
            if columnIndex == 0 {
                currentX = .zero
            }
            let columnWidth = columnWidths[columnIndex]
            subview.place(at: CGPoint(x: bounds.minX+currentX,
                                      y: bounds.minY+currentHeights[columnIndex]),
                          anchor: .topLeading,
                          proposal: ProposedViewSize(width: columnWidth, height: nil))
            let size = subview.sizeThatFits(proposal)
            currentHeights[columnIndex] += size.height
            currentX += columnWidth
        }
    }
}

public struct FixedVGridBalanced: Layout {
    let columns: Int
    let spacing: CGFloat
    let itemAnchor: UnitPoint

    public init(columns: Int, spacing: CGFloat = .zero, itemAnchor: UnitPoint = .center) {
        self.columns = columns
        self.spacing = spacing
        self.itemAnchor = itemAnchor
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var heights: [CGFloat] = Array(repeating: .zero, count: columns)
        var nextIndex = 0
        for (index, subview) in subviews.enumerated() {
            let columnIndex = heights.enumerated().min { $0.element < $1.element }?.offset ?? nextIndex
            nextIndex = (nextIndex + 1) % heights.count
            heights[columnIndex] += subview.sizeThatFits(proposal).height
        }
        return CGSize(width: proposal.width ?? .zero, height: heights.max() ?? .zero)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = .zero
        var currentHeights: [CGFloat] = Array(repeating: .zero, count: columns)
        let columnWidth = bounds.width/CGFloat(columns)

        for (index, subview) in subviews.enumerated() {
            let columnIndex = if index < columns { // first row just go across
                index
            } else {
                currentHeights.enumerated().min { $0.element < $1.element }?.offset ?? 0
            }
            let x = columnWidth * CGFloat(columnIndex)
            let y = currentHeights[columnIndex]

            subview.place(at: CGPoint(x: bounds.minX+x,
                                      y: bounds.minY+currentHeights[columnIndex]),
                          anchor: .topLeading,
                          proposal: ProposedViewSize(width: columnWidth, height: nil))
            let size = subview.sizeThatFits(proposal)
            currentHeights[columnIndex] += size.height
        }
    }
}


