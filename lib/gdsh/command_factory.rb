require_relative 'commands'

##
# Factory pattern to create the appropriate command.
#
module CommandFactory
  include Commands

  def parsed_inputs
    # gets user input, defaulting to empty and removing newline
    user_input = $stdin.gets || ''

    # if command has parameters, split it up
    user_input.chomp.split(/[\(,\),\,]/)
  end

  def next_command
    params = parsed_inputs
    Commands.interpret(params[0]).new(@client, params)
  end
end
