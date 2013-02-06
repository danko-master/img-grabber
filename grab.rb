require 'nokogiri'  
require 'open-uri'
require 'fileutils'

class ImageGrabber   
  def self.get_image(current_url, current_dir)
    if /(http:\/\/.+?)/.match current_url
      current_url = current_url.split('http://')[1]
      #Убираем http:// если его ввели
    end
    begin
      FileUtils.makedirs(current_dir) # Если нет доступа выдаст ошибку
      p "Find or create a folder. Continue..."
      
     current_domain = current_url.match(/(([a-z0-9\-\.]+)?[a-z0-9\-]+(!?\.[a-z]{2,4}))/)[0]
      
      doc = Nokogiri::HTML(open('http://' + current_url))# открываем URL  Веб страницу
      puts "Images of Web Page: "
      img_url = ""
      doc.search('//img').map do |img| #находим все теги img и выводим их
        case img['src']
        when /(http:\/\/.+?)/
          img_url = img['src']
        when /(^\/\/.+?)/
          img_url = img['src'].sub("//", "http://")
        when /(^\/.+?)/
          img_url = 'http://' + current_domain + img['src']
        else
          img_url = 'http://' + current_domain + '/' + img['src']
        end
        p img_url
        img_name = img_url.split('/')[-1]
        #img_name = img_name.split('?')[0]
        p img_name

        open(current_dir + '/' + img_name, 'wb') do |file|
            file << open(img_url).read
            p 'Loaded'
        end
      end
    rescue Errno::EACCES
      p 'Error path or creating folder. Stopping the program.'
    rescue SocketError
      p 'Connection Error. Check the address. Stopping the program.'
    rescue
      p 'Error. Stopping the program.'
    end
  end

  get_image(ARGV[0], ARGV[1])
end
