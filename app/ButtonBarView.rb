#
#  ButtonBar.rb
#  CodeSnippet
#
#  Created by Watson on 11/09/26.
#

class ButtonBarView < NSView

  def initWithFrame(frame)
    if super
      top = NSColor.colorWithCalibratedWhite(250.0/255.0, alpha:1.0)
      bottom = NSColor.colorWithCalibratedWhite(250.0/255.0, alpha:1.0)
      @gradient1 = NSGradient.alloc.initWithStartingColor(top, endingColor:bottom)

      top = NSColor.colorWithCalibratedWhite(230.0/255.0, alpha:1.0)
      bottom = NSColor.colorWithCalibratedWhite(230.0/255.0, alpha:1.0)
      @gradient2 = NSGradient.alloc.initWithStartingColor(top, endingColor:bottom)
      
      @resizeHandleColor = NSColor.colorWithCalibratedWhite(50.0/ 255.0, alpha:0.598)
    end
    return self
  end

  def drawRect(rect)
    # draw gradient
    gradientRect = NSMakeRect(rect.origin.x, rect.size.height/2, rect.size.width, rect.size.height);
    @gradient1.drawInRect(gradientRect, angle:270)

    gradientRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    @gradient2.drawInRect(gradientRect, angle:270)

    # draw handle
    @resizeHandleColor.set
    3.times do |i|
      x = rect.size.width - 15 + i*4 - 0.5
      y = rect.size.height/2 - 5
      
      from = NSMakePoint(x, y)
      to   = NSMakePoint(x, y + 10)
      NSBezierPath.strokeLineFromPoint(from, toPoint:to)
    end

    # draw top-edge line
    from = NSMakePoint(0, rect.size.height)
    to   = NSMakePoint(rect.size.width, rect.size.height)
    
    NSColor.grayColor.set
    NSBezierPath.strokeLineFromPoint(from, toPoint:to)  
  end
end

