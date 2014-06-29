require_relative 'commands'
require_relative 'share'

module Commands
  class ShareReadWrite < Share
    def self.command_name
      'share_read_write'
    end

    def self.function
      'Shares a file with other users by email with read-write permission.'
    end

    def execute
      share_with_email_list('writer')
    end
  end
end
