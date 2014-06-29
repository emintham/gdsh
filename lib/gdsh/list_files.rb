require_relative 'commands'

module Commands
  ##
  # List all files accessible by the application.
  #
  class ListFiles < Command
    def self.command_name
      'ls'
    end

    def self.function
      'List files accessible by this application.'
    end

    def retrieve_file_by_page_token(pagetoken)
      parameters = pagetoken.to_s.empty? ? {} : { pageToken: pagetoken }
      drive = @client.discovered_api('drive', 'v2')
      @client.execute(
        api_method: drive.files.list,
        parameters: parameters)
    end

    def filelist
      puts 'Retrieving list of files accessible...'

      result = []
      page_token = nil

      loop do
        api_result = retrieve_file_by_page_token(page_token)

        if api_result.status == 200
          files = api_result.data
          result.concat(files.items)
          page_token = files.next_page_token
        else
          puts "An error occurred: #{result.data['error']['message']}"
          page_token = nil
        end

        break if page_token.to_s.empty?
      end

      result
    end

    ##
    # Prints out a list of files and their properties (title, id,
    # date uploaded).
    #
    def execute
      filelist.each do |f|
        puts "Title: #{f['title']}"
        puts "id: #{f['id']}"
        puts "created at: #{f['createdDate']}"
        puts ''
      end
    end
  end
end
