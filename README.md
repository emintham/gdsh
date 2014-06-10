# gdsh
A Google Drive shell in Ruby.

## Usage
(adapted from https://developers.google.com/drive/web/quickstart/quickstart-ruby)
1. Set up a project in [Google](https://console.developers.google.com//start/api?id=drive&credential=client_key).
2. Select the created project and select APIs & auth and make sure the status
   is **ON** for the Drive API.
3. In the sidebar on the left, select Credentials and set up new credentials
   for this project.
4. Download (as JSON) or save the client id and client secret.
5. `ruby gdsh.rb <credentials_json>` or `ruby gdsh.rb`. In the former, credentials
   will be automatically retrieved from JSON; in the latter, you will need to
   copy and paste the `client_id` and `client_secret` from the credentials above.
