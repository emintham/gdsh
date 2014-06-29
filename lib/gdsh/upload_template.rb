require_relative 'commands'
require_relative 'mime'

module Commands
  ##
  # Uploads a template to the Drive.
  #
  class UploadTemplate < Command
    include Mime

    def self.command_name
      'upload_template'
    end

    def self.function
      'Uploads a template to the Drive.'
    end

    def insert_schema(title, description, mimetype)
      drive = @client.discovered_api('drive', 'v2')
      drive.files.insert.request_schema.new(
        title: title,
        description: description,
        mimeType: mimetype)
    end

    def insert_file(filename, file, mimetype)
      drive = @client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(filename, mimetype)
      @client.execute(
        api_method: drive.files.insert,
        body_object: file,
        media: media,
        parameters: {
          uploadType: 'multipart',
          convert: 'true',
          alt: 'json' })
    end

    ##
    # Writes a template file to drive.
    #
    def execute
      filename = 'document.txt'
      return unless @client && File.exist?(filename)

      puts 'Writing template to drive.'
      file = insert_schema('My Document', 'A test document', txt)
      insert_file(filename, file, txt)
    end
  end
end
