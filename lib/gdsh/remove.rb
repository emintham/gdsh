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

    def initialize(client, params)
      super(client, params)
      @file_id = @params[1]
    end

    def execute
      drive = @client.discovered_api('drive', 'v2')
      result = @client.execute(
        api_method: drive.files.trash,
        parameters: { fileId: @file_id })
      if result.status != 200
        puts drive_error_string
      else
        puts 'Deleted.'.colorize(:green)
      end
    end
  end
end
