require 'fastlane_core/ui/ui'
require 'json'
require 'rest-client'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class OvoOnetrustHelper
      API_BASE_URL_TEMPLATE = "https://{environment}.onetrust.com".freeze

      # OneTrust API: Scan Apps via API (Integrations)
      # Docs: https://developer.onetrust.com/onetrust/docs/scan-apps-via-api
      #
      # Uploads a mobile build artifact (APK/AAB/IPA) to a OneTrust Integration webhook
      # and triggers an app scan/rescan, depending on the provided dataFields.
      def self.scan_build(build_path:, client_id:, client_secret:, environment:, webhook_id:, app_id:, app_name:, platform:)
        unless File.exist?(build_path) && File.file?(build_path)
          UI.error("Build file not found at path: #{build_path}")
          return nil
        end
        
        access_token = self.generate_access_token(client_id: client_id, client_secret: client_secret, environment: environment)

        unless access_token
          UI.error("Access token generation failed; cannot start upload/scan.")
          return nil
        end

        UI.message("Starting upload of build '#{build_path}' to OneTrust...")

        begin
          # The OneTrust scan endpoint expects `dataFields` as a JSON-encoded string passed in the multipart/form-data payload.
          # Build `dataFields` depending on the scan type:
          # - Rescan: provide `appId` + `platform`
          # - New scan: provide `name` + `platform`
          # Note: `platform` must be either "IOS" or "ANDROID" (uppercase).
          normalized_platform = platform.to_s.strip.upcase

          data_fields_hash =
            if app_id.to_s.strip.length > 0
              { "appId" => app_id, "platform" => normalized_platform }   # rescan
            else
              UI.user_error!("'name' is required when 'app_id' is not provided") if app_name.to_s.strip.empty?
              { "name" => app_name, "platform" => normalized_platform }      # new scan
            end

          data_fields = data_fields_hash.to_json

          # Build the API base url using the environment
          base_url = API_BASE_URL_TEMPLATE.sub '{environment}', environment

          # POST to the Integration webhook URL (copied from the OneTrust workflow).
          # Body type is multipart/form-data with keys: file and dataFields.
          response = RestClient.post(
            "#{base_url}/integrationmanager/api/v1/webhook/#{webhook_id}",
            {
              file: File.new(build_path, "rb"),
              dataFields: data_fields
            },
            {
              content_type: "multipart/form-data",
              Authorization: "Bearer #{access_token}"
            }
          )

          json_response = JSON.parse(response.body)

          # The docs mention a successful request returns 202 and provides a request ID.
          request_id = json_response["requestId"]

          UI.success("Build uploaded successfully to OneTrust. Request ID: #{request_id}")
          request_id
        rescue RestClient::ExceptionWithResponse => e
          UI.error(
            "An error occurred while uploading the build '#{build_path}' to OneTrust.\n" \
            "Status Code: #{e.http_code}\n" \
            "Body: #{e.response}"
          )
          nil
        rescue StandardError => e
          UI.error("An unexpected error occurred: #{e}")
          nil
        end
      end

      # OneTrust API: Get OAuth Token
      # Docs: https://developer.onetrust.com/onetrust/reference/getoauthtoken-1
      #
      # Generates an OAuth 2.0 access token using the client_credentials grant.
      # The returned token can be used to authenticate subsequent API calls (e.g., build upload / app scan).
      def self.generate_access_token(client_id:, client_secret:, environment:)
        UI.message("Generate Access Token...")

        begin
          # Build the API base url using the environment
          base_url = API_BASE_URL_TEMPLATE.sub '{environment}', environment

          # Request an access token via multipart/form-data (as required by the endpoint).
          response = RestClient.post(
            "#{base_url}/api/access/v1/oauth/token",
            {
              grant_type: "client_credentials", # OAuth grant type for server-to-server authentication.
              client_id: client_id,             # OneTrust client credential identifier.
              client_secret: client_secret      # OneTrust client credential secret.
            },
            { content_type: "application/x-www-form-urlencoded" }
          )

          # Parse JSON response and extract the access token.
          json_response = JSON.parse(response.body)
          access_token = json_response["access_token"]

          # Successful request (HTTP 2xx).
          UI.success("Access token created successfully")

          # Return the token to be used by other actions.
          access_token
        rescue RestClient::ExceptionWithResponse => e
          # HTTP error returned by server (e.g., 400, 401, 500).
          UI.error(
            "An error occurred while generating the access token.\n" \
            "Status Code: #{e.http_code}\n" \
            "Body: #{e.response}"
          )
          nil
        rescue StandardError => e
          # Any other unexpected error.
          UI.error("An unexpected error occurred: #{e}")
          nil
        end
      end
    end
  end
end
