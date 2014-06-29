require_relative 'commands'

module Commands
  ##
  # Quit command.
  #
  class Quit < Command
    def self.command_name
      'quit'
    end

    def self.function
      'Exit the application.'
    end

    def self.terminal?
      true
    end

    def execute
    end
  end
end
