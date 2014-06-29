require 'google/api_client'
require 'launchy'
require 'json'
require 'colorize'

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

  ##
  # Authorizes a user. A browser window will pop-out and a token
  # will be granted. The user should copy-paste the token into the
  # command line to authorize access.
  #
  def authorize
    init_client

    uri = @client.authorization.authorization_uri
    Launchy.open(uri)

    # Exchange authorization code for access token
    print 'Enter authorization code: '.colorize(:light_blue)
    @client.authorization.code = $stdin.gets.chomp
    @client.authorization.fetch_access_token!
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
end
