APP_NAME = "CodeSnippet"
CONFIG   = "Release"

desc "Build Application"
task :build do
  sh "xcodebuild -target #{APP_NAME} -configuration #{CONFIG}"
end

desc "Embed MacRuby to Application"
task :embed do
  sh "xcodebuild -target Deployment"
end

desc "Make #{APP_NAME}.dmg"
task :dmg => [:clean, :embed] do
  sh "hdiutil create #{APP_NAME}.dmg -volname #{APP_NAME} -srcfolder build/Release/#{APP_NAME}.app"
end

desc "Clean building files"
task :clean do
  sh "rm -rf build"
  sh "rm -rf #{APP_NAME}.dmg"
end
