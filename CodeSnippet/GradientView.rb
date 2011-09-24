#
#  GradientView.rb
#  CodeSnippet
#
#  Created by Watson on 11/09/24.
#

class GradientView < NSView

  def initWithFrame(frame)
    if super
      top = NSColor.colorWithCalibratedWhite(240.0/255.0, alpha:1.0)
      bottom = NSColor.colorWithCalibratedWhite(200.0/255.0, alpha:1.0)

      @gradient = NSGradient.alloc.initWithStartingColor(top, endingColor:bottom)
    end
    return self
  end

  def drawRect(rect)
    # draw gradient
    @gradient.drawInRect(rect, angle:270)

    # draw bottom-edge line
    startLine = NSPoint.new
    startLine.x = 0
    startLine.y = 0
    endLine = NSPoint.new
    endLine.x = rect.size.width
    endLine.y = 0

    NSColor.grayColor.set
    NSBezierPath.strokeLineFromPoint(startLine, toPoint:endLine)
  end

end
