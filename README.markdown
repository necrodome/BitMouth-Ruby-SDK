Telesocial API Ruby gem
=======================

Telesocial's free calling API enables mobile calling in social networks.
This is a Ruby interface to [Telesocial API](http://sites.telesocial.com/docs/home).

Installation
------------

    gem install telesocial

Usage - Examples
----------------
    ```ruby
    require 'telesocial'
    client = Telesocial::Client.new('your_api_key') # Now, all telesocial methods are available to your client

    # Method calls on the client returns a simple object that matches
    # Telesocial's API response object.

    # Register a user with username "eric" and phone number: 4054441212
    response = client.register("eric", "4054441212")
    puts response.status # => 201
    puts response.uri # => "/api/rest/registrant/eric"

    # Check a user's registration status
    response = begin
                 client.get_registration_status('eric')
               rescue Telesocial::NotFound
                 # Registration not found;
               else
                 # Other errors
               end

    # Upload a file to be played to a registered user
    media_id = client.create_media.mediaId
    upload_request_grant_id = client.request_upload_grant(media_id)

    uploaded_file_url = client.upload_file(upload_request_grant_id, "my_file_path.mp3")
    ```
