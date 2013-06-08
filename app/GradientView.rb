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
    from = NSMakePoint(0, 0)
    to   = NSMakePoint(rect.size.width, 0)

    NSColor.grayColor.set
    NSBezierPath.strokeLineFromPoint(from, toPoint:to)
  end

end
