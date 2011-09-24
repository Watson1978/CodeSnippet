#
#  EditController.rb
#  CodeSnippet
#
#  Created by Watson on 11/09/24.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class EditController
  attr_accessor :delegate
  attr_accessor :entity
  
  # outlet
  attr_accessor :window
  attr_accessor :title
  attr_accessor :language
  attr_accessor :body

  def awakeFromNib
    body.setFont(NSFont.fontWithName("Monaco", size:12))
  end

  def reset
    title.stringValue = ""
    body.string = ""
    language.selectItemWithObjectValue("Other")
  end

  def newSnippet(entity)
    @entity = entity
    window.makeKeyAndOrderFront(nil)
    reset
  end
  
  def editSnippet(entity)
    @entity = entity
    window.makeKeyAndOrderFront(nil)
    
    title.stringValue = @entity.title
    body.string = @entity.body
    language.selectItemWithObjectValue(@entity.language)
  end

  def windowWillClose(aNotification)
    @entity.title = title.stringValue
    @entity.body = body.string.copy

    index = language.indexOfSelectedItem
    if index >= 0
      @entity.language = language.itemObjectValueAtIndex(index)
    end
    @entity.language ||= "Other"
    
    time = Time.now
    @entity.create ||= time
    @entity.update = time
    
    delegate.saveSnippet
    reset
  end
end
