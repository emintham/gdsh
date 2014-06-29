require 'google/api_client'
require 'json'
require 'colorize'

require_relative 'command_mixin'
require_relative 'error'

##
# Commands
#
module Commands
  ##
  # Command with an initialized client object.
  #
  class Command
    include CommandMixin
    include DriveError

    def initialize(client, params)
      @client, @params = client, params
    end
  end

  module_function

  def commands
    constants.select { |c| const_get(c).is_a? Class }
  end

  def puts_usage_header
    puts 'Commands'.colorize(:green)
    puts '--------'.colorize(:green)
  end

  def usage
    puts_usage_header
    commands.each do |c|
      klass = const_get(c)
      puts klass.description unless klass.command_name.empty?
    end
  end

  def interpret(input)
    return Quit if input.nil?

    commands.each do |c|
      klass = const_get(c)
      return klass if input == klass.command_name
    end

    Unrecognized
  end
end
