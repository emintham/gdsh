require 'net/http'
require 'open-uri'
require 'date'

module Download
  def download(filename, url)
    new_filename = DateTime.now.to_s + '_' + url
    filename = (File.exist? filename) ? new_filename : filename
    puts "Downloading #{url}..."
    File.write(filename, Net::HTTP.get(URI.parse(url)))
    puts 'Finished download.'
  end
end

