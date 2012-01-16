APP_NAME = "CodeSnippet"
CONFIG   = "Release"

begin
  info_plist = load_plist(File.read("#{APP_NAME}/#{APP_NAME}-Info.plist"))
  VERSION  = info_plist["CFBundleShortVersionString"].to_s
  raise "can't load Info.plist" if VERSION.length == 0
  DMG_FILE = "#{APP_NAME}-#{VERSION}.dmg"
rescue
  raise "<< This Rakefile depends on MacRuby!! Should run with macrake. >>"
end

task :default => :dmg

desc "Build Application"
task :build do
  sh "xcodebuild -target #{APP_NAME} -configuration #{CONFIG}"
end

desc "Embed MacRuby to Application"
task :embed do
  sh "xcodebuild -target Deployment"
end

desc "Make #{DMG_FILE}"
task :dmg => [:clean, :embed] do
  sh "hdiutil create #{DMG_FILE} -volname #{APP_NAME} -srcfolder build/Release/#{APP_NAME}.app"
end

desc "Clean building files"
task :clean do
  sh "rm -rf build"
  sh "rm -rf #{DMG_FILE}"
end
