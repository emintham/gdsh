require 'google/api_client'
require 'json'

require_relative 'mime'

##
# Factory pattern to create the appropriate command.
#
module CommandFactory
  def usage_string
    <<-eos

    Commands
    --------
    quit: 
      Exits the shell.
    help: 
      Prints this help.
    ls: 
      List files accessible by this application.
    upload_template: 
      Writes a test file to Drive.
    query(<file_id>): 
      Queries all revisions for <file_id>.
    get(<file_id>[,<revision_number]): 
      Downloads a specific revision of a file if <revision_number> is
      specified; downloads all revisions otherwise.

    eos
  end

  def interpret_input
    # gets user input, defaulting to empty and removing newline
    user_input = $stdin.gets || ''

    # if command has parameters, split it up
    user_input.chomp.split(/[\(,\),\,]/)
  end

  def next_command(client)
    params = interpret_input

    case params[0]
    when 'quit', '', nil
      Quit.new
    when 'help'
      Help.new
    when 'ls'
      ListFiles.new(client, params)
    when 'upload_template'
      UploadTemplate.new(client, params)
    when 'query'
      QueryRevision.new(client, params)
    when 'get'
      GetFile.new(client, params)
    else
      Unrecognized.new(client, params)
    end
  end
end

##
# Command mixin
#
module CommandMixin
  def name
  end

  def function
  end

  def initialize
  end

  def execute
    fail 'Method not implemented.'
  end

  def description
    name + ': ' + function
  end

  def terminal?
    false
  end
end

##
# Command with an initialized client object.
#
class Command
  include CommandMixin

  def initialize(client, params)
    @client, @params = client, params
  end
end

class Help < Command
  include CommandFactory

  def initialize
  end

  def name
    'help'
  end

  def function
    'Returns this usage information.'
  end

  def execute
    puts usage_string
  end
end

##
# Unrecognized command.
#
class Unrecognized < Command
  def execute
    "Command not recognized, got: #{@params}"
  end
end

##
# Quit command.
#
class Quit < Command
  def initialize
  end

  def name
    'quit'
  end

  def function
    'Exit the application.'
  end

  def terminal?
    true
  end
end

##
# List all files accessible by the application.
#
class ListFiles < Command
  def name
    'ls'
  end

  def function
    'List files accessible by this application.'
  end

  ##
  # Retrieve a list of File resources.
  #
  def retrieve_all_files
    client = @client
    puts 'Retrieving list of files accessible...'

    drive = client.discovered_api('drive', 'v2')
    result = []
    page_token = nil

    loop do
      parameters = {}
      parameters['pageToken'] = page_token if page_token.to_s != ''

      api_result = client.execute(
        api_method: drive.files.list,
        parameters: parameters)
      if api_result.status == 200
        files = api_result.data
        result.concat(files.items)
        page_token = files.next_page_token
      else
        puts "An error occurred: #{result.data['error']['message']}"
        page_token = nil
      end

      break unless page_token.to_s != ''
    end

    puts 'Done.'
    @files = result
  end

  ##
  # Prints out a list of files and their properties (title, id,
  # date uploaded).
  #
  def print_files
    @files.each do |f|
      puts "Title: #{f['title']}"
      puts "id: #{f['id']}"
      puts "created at: #{f['createdDate']}"
      puts ''
    end
  end

  def execute
    retrieve_all_files
    print_files
  end
end

##
# Uploads a template to the Drive.
#
class UploadTemplate < Command
  def name
    'upload_template'
  end

  def function
    'Uploads a template to the Drive.'
  end

  ##
  # Writes a template file to drive.
  #
  def execute
    return unless @client

    client = @client
    drive = client.discovered_api('drive', 'v2')

    puts 'Writing template to drive.'
    # Insert a file
    file = drive.files.insert.request_schema.new(
      title: 'My document',
      description: 'A test document',
      mimeType: 'text/plain')

    media = Google::APIClient::UploadIO.new('document.txt', 'text/plain')
    client.execute(
      api_method: drive.files.insert,
      body_object: file,
      media: media,
      parameters: {
        uploadType: 'multipart',
        convert: 'true',
        alt: 'json' })
    puts 'Done.'
  end
end

##
# Queries all revisions of a file.
#
class QueryRevision < Command
  include Mime

  def name
    'query(<file_id>)'
  end

  def function
    'Queries all revisions of a file.'
  end

  def initialize(client, params)
    super(client, params)
    @file_id = params[1]
  end

  def revisions
    client = @client
    drive = client.discovered_api('drive', 'v2')
    api_result = client.execute(
      api_method: drive.revisions.list,
      parameters: { 'fileId' => @file_id })
    if api_result.status == 200
      revisions = api_result.data
      revisions.items
    else
      puts "An error occurred: #{result.data['error']['message']}"
    end
  end

  ##
  # Query revisions of a file
  #
  def execute
    print_revisions
  end

  ##
  # Print consolidated revisions of a file
  #
  def print_revisions
    return if revisions.nil?

    puts 'Revisions:'
    revisions.each do |r|
      puts "Revision id: #{r['id']}"
      puts "Modified: #{r['modifiedDate']}"
      puts "Modifying User: #{r['lastModifyingUserName']}"
      puts "Download pdf: #{r['exportLinks'][pdf]}"
      puts "Download docx: #{r['exportLinks'][docx]}"
      puts ''
    end
  end

  def txt_link(revision)
    rev = revisions.select { |r| r['id'] == revision }
    # should only have one element if revision exists
    rev.first['exportLinks'][txt] unless rev.empty?
  end
end

class GetFile < QueryRevision
  def name
    'get(<file_id>[,<revision_number>]'
  end

  def function
    'Downloads a specific revision of a file if <revision_number> is ' \
    'specified; downloads all revisions otherwise.'
  end

  def initialize(client, params)
    super(client, params)
    @revision = (params.length == 3) ? params[2] : nil
  end

  def filename(rev)
    @file_id.to_s + '_rev_' + rev.to_s
  end

  def download(filename)
  end

  def execute
    if @revision.nil?
      revisions.each do |r|
        download(filename(r['id']), txt_link(r['id']))
      end
    else
      download(filename(@revision), txt_link(@revision))
    end
  end
end
