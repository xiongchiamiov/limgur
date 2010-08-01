require 'test/helper'

class LimgurTest < Test::Unit::TestCase
  setup do
    FileUtils.mkdir 'tmp'
    FileUtils.cp Dir.glob('test/*.jpg'), 'tmp/'

    @limgur = Limgur.new('90b4d040607755992895fdd5bb586ba2')
  end

  teardown do
    FileUtils.rm_rf 'tmp'
  end

  context 'uploading an image' do
    test 'does indeed upload an image' do
      upload = @limgur.upload 'tmp/test.jpg', {:format => 'S', :output => 'plaintext'}

      assert_equal "ok\n", upload
    end
    
    test 'uploads an image with spaces in the name' do
      upload = @limgur.upload 'tmp/test with spaces.jpg', {:format => 'S', :output => 'plaintext'}
      
      assert_equal "ok\n", upload
    end
    
    test 'uploads an image from a url' do
      upload = @limgur.upload 'http://github.com/xiongchiamiov/limgur/raw/master/test/test.jpg', {:format => 'S', :output => 'plaintext'}
      
      assert_equal "ok\n", upload
    end
    
    test 'does not upload an invalid image' do
      stderr = $stderr
      $stderr = File.new('/dev/null', 'w')
      upload = @limgur.upload 'test_empty.jpg', {:format => 'S', :output => 'plaintext'}
      $stderr = stderr
      
      assert_equal "invalid image\n", upload
    end
    
    test 'pays attention to format options' do
      upload = @limgur.upload 'tmp/test.jpg', {:format => 'fIDilsrdSn', :output => 'plaintext'}
      upload = upload.split("\n")
      
      assert_equal 'tmp/test.jpg', upload[0]
      assert_match /\w+/, upload[1]
      assert_match /\w+/, upload[2]
      assert_match /http:\/\/i\.imgur\.com\/\w+\.\w+/, upload[3]
      assert_match /http:\/\/i\.imgur\.com\/\w+l\.\w+/, upload[4]
      assert_match /http:\/\/i\.imgur\.com\/\w+s\.\w+/, upload[5]
      assert_match /http:\/\/imgur\.com\/\w+/, upload[6]
      assert_match /http:\/\/imgur\.com\/delete\/\w+/, upload[7]
      assert_match /\w+/, upload[8]
      assert_equal nil, upload[9]
    end
    
    test 'outputs bbCode when asked to' do
      upload = @limgur.upload 'tmp/test.jpg', {:format => 'ilsrd', :output => 'bbcode'}
      upload = upload.split("\n")
      
      assert_match /\[img\]http:\/\/i.imgur.com\/\w+\.\w+\[\/img\]/, upload[0]
      assert_match /\[url=http:\/\/i.imgur.com\/\w+\.\w+\]\[img\]http:\/\/i.imgur.com\/\w+l\.\w+\[\/img\]\[\/url\]/, upload[1]
      assert_match /\[url=http:\/\/i.imgur.com\/\w+\.\w+\]\[img\]http:\/\/i.imgur.com\/\w+s\.\w+\[\/img\]\[\/url\]/, upload[2]
      assert_match /\[url=http:\/\/imgur.com\/\w+\]Imgur\[\/url\]/, upload[3]
      assert_match /\[url=http:\/\/imgur.com\/delete\/\w+\]Delete\[\/url\]/, upload[4]
    end
    
    test 'outputs HTML when asked to' do
      upload = @limgur.upload 'tmp/test.jpg', {:format => 'ilsrd', :output => 'html'}
      upload = upload.split("\n")
      
      assert_match /<img src="http:\/\/i.imgur\.com\/\w+\.\w+" \/>/, upload[0]
      assert_match /<a href="http:\/\/i\.imgur\.com\/\w+\.\w+"><img src="http:\/\/i.imgur\.com\/\w+l\.\w+" \/><\/a>/, upload[1]
      assert_match /<a href="http:\/\/i\.imgur\.com\/\w+\.\w+"><img src="http:\/\/i.imgur\.com\/\w+s\.\w+" \/><\/a>/, upload[2]
      assert_match /<a href="http:\/\/imgur\.com\/\w+">Imgur<\/a>/, upload[3]
      assert_match /<a href="http:\/\/imgur\.com\/delete\/\w+">Delete<\/a>/, upload[4]
    end
    
    test 'outputs titles when asked to' do
      upload = @limgur.upload 'tmp/test.jpg', {:format => 'fIDilsrdS', :output => 'titles'}
      upload = upload.split("\n").map {|line| line.split(':')[0]}
      
      assert_equal 'File', upload[0]
      assert_equal 'Image hash', upload[1]
      assert_equal 'Delete hash', upload[2]
      assert_equal 'Original image', upload[3]
      assert_equal 'Large thumbnail', upload[4]
      assert_equal 'Small thumbnail', upload[5]
      assert_equal 'Imgur page', upload[6]
      assert_equal 'Delete page', upload[7]
      assert_equal 'Status', upload[8]
    end
  end

  context 'deleting an image' do
    test 'effectively deletes it' do
      upload = @limgur.upload 'tmp/test.jpg'
      hash   = upload.split("\n")[3].gsub('Delete hash:  ', '')
      delete = @limgur.delete hash

      assert_equal 'Image was successfully deleted!', delete
    end
  end

  context 'using scrot' do
    test 'saves a screenshot with default name if not given' do
      filename = Time.now.to_s.gsub(' ', '').gsub(':', '') + '.png'
      
      begin
        screenshot = @limgur.scrot
        assert_equal true, File.exists?(filename)
  
        FileUtils.rm filename
      rescue => e
        if e.message == "scrot not installed"
          omit "Scrot not installed"
        else
          raise e
        end
      end
    end

    test 'saves a screenshot with filename given' do
      begin
        screenshot = @limgur.scrot 'tmp/screenshot.png'
        assert_equal true, File.exists?('tmp/screenshot.png')
      rescue => e
        if e.message == "scrot not installed"
          omit "Scrot not installed"
        else
          raise e
        end
      end
    end
  end
end
