require_relative 'commands'
require_relative 'share'

module Commands
  class ShareReadOnly < Share
    def self.command_name
      'share_read_only'
    end

    def self.function
      'Shares a file with other users by email with read-only permission.'
    end

    def execute
      share_with_email_list('reader')
    end
  end
end
