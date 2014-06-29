require_relative 'commands'

module Commands
  class Remove < Command
    def self.command_name
      'rm'
    end

    def self.parameters
      '(<file_id>)'
    end

    def self.function
      'Removes the file.'
    end

    def execute
      drive = @client.discovered_api('drive', 'v2')
      result = @client.execute(
        api_method: drive.files.trash,
        parameters: { fileId: @params[1] })
      if result.status != 200
        puts "An error occurred: #{result.data['error']['message']}"
      else
        puts 'Deleted.'
      end
    end
  end
end
