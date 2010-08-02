# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'limgur'
  s.version = "2.0.0"
  s.date = Time.now.strftime('%Y-%m-%d')

  s.authors = ["xiongchiamiov", "dannytatom"]
  s.email = ['xiong.chiamiov@gmail.com', 'dannytatom@gmail.com']
  
  s.add_dependency 'curb'
  s.add_dependency 'crack'
  s.add_development_dependency 'contest'
  s.add_development_dependency 'test-unit'
  
  s.files = %w( LICENSE Rakefile README.md )
  s.files += Dir.glob "bin/*"
  s.files += Dir.glob "lib/**/*"
  s.files += Dir.glob "test/**/*"
  
  s.executables = 'limgur'
  s.test_files = Dir.glob "test/test_*.rb"
  s.extra_rdoc_files = ['README.md']
  
  s.summary = %q{CLI to Imgur}
  s.homepage = 'http://github.com/xiongchiamiov/limgur'
  s.description = %q{CLI to Imgur, letting you upload and delete images.  If you've got scrot installed, you can also take a screenshot and upload it in one command.}
end
