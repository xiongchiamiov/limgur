require 'test/helper'

class LimgurTest < Test::Unit::TestCase
  setup do
    FileUtils.mkdir 'tmp'
    FileUtils.cp 'test/test.jpg', 'tmp/test.jpg'

    @limgur = Limgur.new('6ea137d641083e7ef128c6bcd8a32683')
  end

  teardown do
    FileUtils.rm_rf 'tmp'
  end

  context 'uploading an image' do
    test 'does indeed upload an image' do
      upload = @limgur.upload 'tmp/test.jpg'

      assert_equal 'Image was uploaded successfully!', upload.split("\n").first
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
    
      screenshot = @limgur.scrot
      assert_equal true, File.exists?(filename)

      FileUtils.rm filename
    end

    test 'saves a screenshot with filename given' do
      screenshot = @limgur.scrot 'tmp/screenshot.png'
      assert_equal true, File.exists?('tmp/screenshot.png')
    end
  end
end
