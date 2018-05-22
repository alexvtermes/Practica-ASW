OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, '323632880151-021adosf6m80llcieeba79e4cjvf6kp6.apps.googleusercontent.com', 'UVY3fiSeWnjefppOoXdNP1qR', {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end