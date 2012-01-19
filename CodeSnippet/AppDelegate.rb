#
#  AppDelegate.rb
#  CodeSnippet
#
#  Created by Watson on 11/09/23.
#

class AppDelegate
  attr_accessor :window
  attr_accessor :arrayController
  attr_accessor :snippet
  attr_accessor :codeTitle
  attr_accessor :codeLanguage
  attr_accessor :webView

  attr_accessor :editController

  BRUSHES = {
    'HTML'        => {'brush' => 'html', 'brushFile' => 'shBrushXml.js'},
    'CSS'         => {'brush' => 'css', 'brushFile' => 'shBrushCss.js'},
    'JavaScript'  => {'brush' => 'js', 'brushFile' => 'shBrushJScript.js'},
    'Ruby'        => {'brush' => 'ruby', 'brushFile' => 'shBrushRuby.js'},
    'Python'      => {'brush' => 'python', 'brushFile' => 'shBrushPython.js'},
    'Perl'        => {'brush' => 'perl', 'brushFile' => 'shBrushPerl.js'},
    'C, C++'      => {'brush' => 'cpp', 'brushFile' => 'shBrushCpp.js'},
    'Objective-C' => {'brush' => 'cpp', 'brushFile' => 'shBrushCpp.js'},
    'Java'        => {'brush' => 'java', 'brushFile' => 'shBrushJava.js'},
    'Shell'       => {'brush' => 'shell', 'brushFile' => 'shBrushBash.js'},
  }

  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application
    editController.delegate = self
  end

  def windowWillClose(aNotification)
    NSApp.terminate(self)
  end

  def newSnippet(sender)
    makeEntity do |entity|
      editController.newSnippet(entity)
    end
  end

  def editSnippet(sender)
    selectedEntity do |entity|
      editController.editSnippet(entity)
    end
  end

  def copySnippet(sender)
    selectedEntity do |entity|
      pboard = NSPasteboard.generalPasteboard
      pboard.declareTypes([NSStringPboardType], owner:nil)
      pboard.setString(entity.body, forType:NSStringPboardType)
    end
  end

  def deleteSnippet(sender)
    selectedEntity do |entity|
      managedObjectContext.deleteObject(entity)
    end
  end
  
  def makeEntity
    entity = NSEntityDescription.insertNewObjectForEntityForName("Snippet", inManagedObjectContext:managedObjectContext)
    yield entity
  end
  
  def selectedEntity
    entity = arrayController.selectedObjects.last
    return if entity.nil?
    yield entity
  end

  def saveSnippet
    saveAction(nil)

    # reload WebView
    loadSnippet
  end

  def tableViewSelectionDidChange(aNotification)
    loadSnippet
  end
  
  def loadSnippet
    selectedEntity do |entity|
      codeTitle.stringValue = entity.title
      codeLanguage.stringValue = entity.language

      res_path = NSBundle.mainBundle.resourcePath
      nsurl = NSURL.URLWithString(res_path)

      snippet_body = escape(entity.body)
      brush = BRUSHES[entity.language]
      brush ||= {'brush' => 'text', 'brushFile' => 'shBrushPlain.js'}
      html =<<"EOS"
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="#{res_path}/shCore.js"></script>
<script type="text/javascript" src="#{res_path}/#{brush['brushFile']}"></script>
<link type="text/css" rel="stylesheet" href="#{res_path}/shCoreDefault.css">
<script type="text/javascript">SyntaxHighlighter.all();</script>
<style type="text/css">
.toolbar { display: none !important;}
</style>
</head>
<body>
<pre class="brush: #{brush['brush']};">#{snippet_body}</pre>
</body>
</html>
EOS
      webView.mainFrame.loadHTMLString(html, baseURL:nsurl)
    end
  end

  def escape(string)
    str = string.dup
    str.gsub!(/&/, '&amp;')
    str.gsub!(/</, '&lt;')
    str.gsub!(/>/, '&gt;')
    return str
  end

  # Persistence accessors
  attr_reader :persistentStoreCoordinator
  attr_reader :managedObjectModel
  attr_reader :managedObjectContext

  #
  # Returns the directory the application uses to store the Core Data store file. This code uses a directory named "CodeSnippet" in the user's Library directory.
  #
  def applicationFilesDirectory
    file_manager = NSFileManager.defaultManager
    library_url = file_manager.URLsForDirectory(NSLibraryDirectory, inDomains:NSUserDomainMask).lastObject
    library_url.URLByAppendingPathComponent("CodeSnippet")
  end

  #
  # Creates if necessary and returns the managed object model for the application.
  #
  def managedObjectModel
    unless @managedObjectModel
      model_url = NSBundle.mainBundle.URLForResource("CodeSnippet", withExtension:"momd")
      @managedObjectModel = NSManagedObjectModel.alloc.initWithContentsOfURL(model_url)
    end

    @managedObjectModel
  end

  #
  # Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
  #
  def persistentStoreCoordinator
    return @persistentStoreCoordinator if @persistentStoreCoordinator

    mom = self.managedObjectModel
    unless mom
      puts "#{self.class} No model to generate a store from"
      return nil
    end

    file_manager = NSFileManager.defaultManager
    directory = self.applicationFilesDirectory
    error = Pointer.new_with_type('@')

    properties = directory.resourceValuesForKeys([NSURLIsDirectoryKey], error:error)

    if properties.nil?
      ok = false
      if error[0].code == NSFileReadNoSuchFileError
        ok = file_manager.createDirectoryAtPath(directory.path, withIntermediateDirectories:true, attributes:nil, error:error)
      end
      if ok == false
        NSApplication.sharedApplication.presentError(error[0])
      end
    elsif properties[NSURLIsDirectoryKey] != true
      # Customize and localize this error.
      failure_description = "Expected a folder to store application data, found a file (#{directory.path})."

      error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code:101, userInfo:{NSLocalizedDescriptionKey => failure_description})

      NSApplication.sharedApplication.presentError(error)
      return nil
    end

    url = directory.URLByAppendingPathComponent("CodeSnippet.storedata")
    @persistentStoreCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(mom)

    unless @persistentStoreCoordinator.addPersistentStoreWithType(NSXMLStoreType, configuration:nil, URL:url, options:nil, error:error)
      NSApplication.sharedApplication.presentError(error[0])
      return nil
    end

    @persistentStoreCoordinator
  end

  #
  # Returns the managed object context for the application (which is already
  # bound to the persistent store coordinator for the application.)
  #
  def managedObjectContext
    return @managedObjectContext if @managedObjectContext
    coordinator = self.persistentStoreCoordinator

    unless coordinator
      dict = {
        NSLocalizedDescriptionKey => "Failed to initialize the store",
        NSLocalizedFailureReasonErrorKey => "There was an error building up the data file."
      }
      error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code:9999, userInfo:dict)
      NSApplication.sharedApplication.presentError(error)
      return nil
    end

    @managedObjectContext = NSManagedObjectContext.alloc.init
    @managedObjectContext.setPersistentStoreCoordinator(coordinator)

    @managedObjectContext
  end

  #
  # Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
  #
  def windowWillReturnUndoManager(window)
    self.managedObjectContext.undoManager
  end

  #
  # Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
  #
  def saveAction(sender)
    error = Pointer.new_with_type('@')

    unless self.managedObjectContext.commitEditing
      puts "#{self.class} unable to commit editing before saving"
    end

    unless self.managedObjectContext.save(error)
      NSApplication.sharedApplication.presentError(error[0])
    end
  end

  def applicationShouldTerminate(sender)
    # Save changes in the application's managed object context before the application terminates.

    return NSTerminateNow unless @managedObjectContext

    unless self.managedObjectContext.commitEditing
      puts "%@ unable to commit editing to terminate" % self.class
    end

    unless self.managedObjectContext.hasChanges
      return NSTerminateNow
    end

    error = Pointer.new_with_type('@')
    unless self.managedObjectContext.save(error)
      # Customize this code block to include application-specific recovery steps.
      return NSTerminateCancel if sender.presentError(error[0])

      alert = NSAlert.alloc.init
      alert.messageText = "Could not save changes while quitting. Quit anyway?"
      alert.informativeText = "Quitting now will lose any changes you have made since the last successful save"
      alert.addButtonWithTitle "Quit anyway"
      alert.addButtonWithTitle "Cancel"

      answer = alert.runModal
      return NSTerminateCancel if answer == NSAlertAlternateReturn
    end

    NSTerminateNow
  end
end

