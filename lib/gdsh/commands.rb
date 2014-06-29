require 'google/api_client'
require 'json'

require_relative 'command_mixin'

##
# Commands
#
module Commands
  ##
  # Command with an initialized client object.
  #
  class Command
    include CommandMixin

    def initialize(client, params)
      @client, @params = client, params
    end
  end

  module_function

  def commands
    constants.select { |c| const_get(c).is_a? Class }
  end

  def usage
    puts 'Commands'
    puts '--------'
    commands.each do |c|
      puts const_get(c).description unless const_get(c).command_name.empty?
    end
  end

  def interpret(input)
    return Quit if input.nil?

    commands.each do |c|
      return const_get(c) if input == const_get(c).command_name
    end

    Unrecognized
  end
end
