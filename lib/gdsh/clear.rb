require_relative 'commands'

module Commands
  ##
  # Clear screen.
  #
  class Clear < Command
    def self.command_name
      'clear'
    end

    def self.function
      'Clears the screen.'
    end

    def execute
      system('clear') || system('cls')
    end
  end
end
