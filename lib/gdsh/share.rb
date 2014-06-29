require_relative 'commands'

module Commands
  class Share < Command
    attr_reader :email_list

    def self.parameters
      '(<file_id>[, <email_1>, <email_2>, ...])'
    end

    def initialize(client, params)
      super(client, params)
      @email_list = []
      @file_id = @params[1]
      @params.drop(2).each do |email|
        @email_list << email
      end
    end

    def share_with_email(email, role)
      drive = @client.discovered_api('drive', 'v2')
      new_permission = drive.permissions.insert.request_schema.new(
        value: email,
        type: 'user',
        role: role)
      result = @client.execute(
        api_method: drive.permissions.insert,
        body_object: new_permission,
        parameters: { fileId: @file_id })
      if result.status == 200
        return result.data
      else
        puts drive_error_string
      end
    end

    def share_with_email_list(role)
      return if @email_list.empty?
      @email_list.each do |email|
        share_with_email(email, role)
      end
    end
  end
end
