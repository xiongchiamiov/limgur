require 'open-uri'
require 'curb'
require 'crack/json'

class Limgur
  def initialize key
    @key = key
  end

  def upload image, options={}
    options = {:format => 'Sridn', :output => 'titles'}.merge options
    isURL = true
    begin
      if isURL && URI.parse(image).scheme
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

      if response['rsp']['stat'] == 'fail'
        $stderr.puts response['rsp']['error_msg']
        "fail\n" if options[:format].count('S') > 0
      else
        output = ''
        
        options[:format].each_char do |char|
          case char
          when 'f'
            output << 'File:            ' if options[:output] == 'titles'
            output << image
          when 'I'
            output << 'Image hash:      ' if options[:output] == 'titles'
            output << response['rsp']['image']['image_hash']
          when 'D'
            output << 'Delete hash:     ' if options[:output] == 'titles'
            output << response['rsp']['image']['delete_hash']
          when 'i'
            output << 'Original image:  ' if options[:output] == 'titles'
            output << '[img]'             if options[:output] == 'bbcode'
            output << '<img src="'        if options[:output] == 'html'
            output << response['rsp']['image']['original_image']
            output << '" />'              if options[:output] == 'html'
            output << '[/img]'            if options[:output] == 'bbcode'
          when 'l'
            output << 'Large thumbnail: ' if options[:output] == 'titles'
            output << "[url=#{response['rsp']['image']['original_image']}][img]" if options[:output] == 'bbcode'
            output << '<a href="' << response['rsp']['image']['original_image'] << '"><img src="' if options[:output] == 'html'
            output << response['rsp']['image']['large_thumbnail']
            output << '" /></a>'          if options[:output] == 'html'
            output << '[/img][/url]'      if options[:output] == 'bbcode'
          when 's'
            output << 'Small thumbnail: ' if options[:output] == 'titles'
            output << "[url=#{response['rsp']['image']['original_image']}][img]" if options[:output] == 'bbcode'
            output << '<a href="' << response['rsp']['image']['original_image'] << '"><img src="' if options[:output] == 'html'
            output << response['rsp']['image']['small_thumbnail']
            output << '" /></a>'          if options[:output] == 'html'
            output << '[/img][/url]'      if options[:output] == 'bbcode'
          when 'r'
            output << 'Imgur page:      ' if options[:output] == 'titles'
            output << '[url='             if options[:output] == 'bbcode'
            output << '<a href="'         if options[:output] == 'html'
            output << response['rsp']['image']['imgur_page']
            output << '">Imgur</a>'       if options[:output] == 'html'
            output << ']Imgur[/url]'      if options[:output] == 'bbcode'
          when 'd'
            output << 'Delete page:     ' if options[:output] == 'titles'
            output << '[url='             if options[:output] == 'bbcode'
            output << '<a href="'         if options[:output] == 'html'
            output << response['rsp']['image']['delete_page']
            output << '">Delete</a>'       if options[:output] == 'html'
            output << ']Delete[/url]'      if options[:output] == 'bbcode'
          when 'S'
            output << 'Status:          ' if options[:output] == 'titles'
            output << response['rsp']['stat']
          when 'n'
          else
            $stderr.puts "#{char} not recognized as a format character!"
          end
          output << "\n"
        end
        
        return output
      end
    rescue URI::InvalidURIError
      isURL = false
      retry
    rescue Curl::Err::ReadError
      $stderr.puts 'Please provide a valid image.'
      "invalid image\n" if options[:format].count('S') > 0
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

    if !(system 'scrot ' + filename)
      raise "scrot not installed"
    end
    upload File.expand_path filename
  end

  def self.version
    '1.0.2'
  end
end
