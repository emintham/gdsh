require_relative 'commands'

module Commands
  ##
  # Unrecognized command.
  #
  class Unrecognized < Command
    def execute
      "Command not recognized, got: #{@params}"
    end
  end
end
