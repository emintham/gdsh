require 'colorize'

module DriveError
  def drive_error_string
    puts "An error occurred: #{result.data['error']['message']}".colorize(:red)
  end
end
