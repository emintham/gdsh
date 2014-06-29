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

    def puts_banner
      puts 'Retrieving list of files accessible...'.colorize(:green)
    end

    def filelist
      puts_banner

      result = []
      page_token = nil

      loop do
        api_result = retrieve_file_by_page_token(page_token)

        if api_result.status == 200
          files = api_result.data
          result.concat(files.items)
          page_token = files.next_page_token
        else
          drive_error_string
          page_token = nil
        end

        break if page_token.to_s.empty?
      end

      result
    end

    def title_label
      "Title: ".colorize(:light_magenta)
    end

    def id_label
      "id: ".colorize(:light_magenta)
    end

    def created_at_label
      "created at: ".colorize(:light_magenta)
    end

    def puts_file_info(f)
      puts title_label + "#{f['title']}"
      puts id_label + "#{f['id']}"
      puts created_at_label + "#{f['createdDate']}"
      puts ''
    end

    def execute
      filelist.each do |f|
        next if f['labels']['trashed']
        puts_file_info(f)
      end
    end
  end
end
