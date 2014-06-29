require_relative 'commands'

module Commands
  ##
  # Help command
  #
  class Help < Command
    def self.command_name
      'help'
    end

    def self.function
      'Returns this usage information.'
    end

    def execute
      Commands.usage
    end
  end
end
