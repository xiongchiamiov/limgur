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
      upload = @limgur.upload 'tmp/test.jpg'

      assert_equal 'Image was uploaded successfully!', upload.split("\n").first
    end
    
    test 'uploads an image with spaces in the name' do
      upload = @limgur.upload 'tmp/test with spaces.jpg'
      
      assert_equal 'Image was uploaded successfully!', upload.split("\n").first
    end
    
    test 'uploads an image from a url' do
      upload = @limgur.upload 'http://github.com/xiongchiamiov/limgur/raw/master/test/test.jpg'
      
      assert_equal 'Image was uploaded successfully!', upload.split("\n").first
    end
    
    test 'does not upload an invalid image' do
      upload = @limgur.upload 'test_empty.jpg'
      
      assert_equal 'Please provide a valid image.', upload
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
