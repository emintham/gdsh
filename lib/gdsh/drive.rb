require 'google/api_client'
require 'launchy'
require 'json'
require 'colorize'
require 'yaml'

##
# DriveService module implements a service that interfaces with
# Google Drive using Google Drive API.
#
class DriveService
  ##
  # Creates a new Google Drive Shell object.
  #
  # @param [String] filename
  #   filename of json containing credentials downloaded from Google.
  #
  def initialize(filename = nil)
    # default to per-file permissions
    @oauth_scope = 'https://www.googleapis.com/auth/drive.file'
    @redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    @filename = filename

    if filename && File.exist?(filename)
      credentials_from_file
    else
      credentials_from_stdin
    end
  end

  def credentials_from_file
    File.open(@filename, 'r') do |f|
      buffer = f.read
      credentials = JSON.parse(buffer)
      @client_id = credentials['installed']['client_id']
      @client_secret = credentials['installed']['client_secret']
    end
  end

  def init_client
    # Create a new API client & load the Google Drive API
    @client = Google::APIClient.new

    # Request authorization
    @client.authorization.client_id = @client_id
    @client.authorization.client_secret = @client_secret
    @client.authorization.scope = @oauth_scope
    @client.authorization.redirect_uri = @redirect_uri
  end

  def puts_refresh_error
    puts "Could not refresh token from saved session.".colorize(:red)
  end

  def authorize
    init_client

    begin
      authorize_from_refresh_token
    rescue
      puts_refresh_error
      authorize_from_authorization_code
    ensure
      @client.authorization.fetch_access_token!
    end
  end

  def authorize_from_refresh_token
    raise StandardError unless File.exist?('.session.yaml')

    f = File.open('.session.yaml', 'r')
    session = YAML.load(f.read)
    @client.authorization.grant_type = 'refresh_token'
    @client.authorization.refresh_token = session.authorization.refresh_token
    f.close
  end

  def authorize_from_authorization_code
    uri = @client.authorization.authorization_uri
    Launchy.open(uri)

    # Exchange authorization code for access token
    print 'Enter authorization code: '.colorize(:light_blue)
    @client.authorization.code = $stdin.gets.chomp
  end

  ##
  # Get credentials from shell if no credentials file was specified.
  #
  def credentials_from_stdin
    # get preset if exists
    @client_id ||= ''
    @client_secret ||= ''

    # Ask from user otherwise
    if @client_id == ''
      print 'Please enter your client id: '
      @client_id = $stdin.gets.chomp
    end

    if @client_secret == ''
      print 'Please enter your client secret: '
      @client_secret = $stdin.gets.chomp
    end
  end

  def write_session_info_to_file
    return if @client.nil?
    f = File.new('.session.yaml', 'w')
    f.write(@client.to_yaml)
    f.close
  end
end
