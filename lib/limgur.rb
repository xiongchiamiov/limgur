require 'open-uri'
require 'curb'
require 'crack/json'

class Limgur
  def initialize key
    @key = key
  end

  def upload image
    begin
      if URI.parse(image).scheme
        c = Curl::Easy.new 'http://imgur.com/api/upload.json'
        c.http_post Curl::PostField.content('key', @key),
                    Curl::PostField.content('image', image)
        response = Crack::JSON.parse c.body_str
      else
        c = Curl::Easy.new 'http://imgur.com/api/upload.json'
        c.multipart_form_post = true
        c.http_post Curl::PostField.content('key', @key),
                    Curl::PostField.file('image', image)
        response = Crack::JSON.parse c.body_str
      end

      if response['error']
        response['error']['error_msg']
      else
        "Image was uploaded successfully!\n\n" \
        "Imgur page:     #{response['rsp']['image']['imgur_page']}\n" \
        "Original image: #{response['rsp']['image']['original_image']}\n" \
        "Delete hash:    #{response['rsp']['image']['delete_hash']}\n"
      end
    rescue
      Curl::Err::ReadError
      'Please provide a valid image.'
    end
  end

  def delete hash
    c = Curl::Easy.new "http://imgur.com/api/delete/#{hash}.json"
    c.http_get
    response = Crack::JSON.parse c.body_str

    if response['error']
      response['error']['error_msg']
    else
      'Image was successfully deleted!'
    end
  end

  def scrot filename=nil
    filename = Time.now.to_s.gsub(' ', '').gsub(':', '') + '.png' if filename.nil?

    system 'scrot ' + filename
    upload File.expand_path filename
  end

  def self.version
    '1.0.1'
  end
end
