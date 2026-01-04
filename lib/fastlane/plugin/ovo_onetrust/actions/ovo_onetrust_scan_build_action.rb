require 'fastlane/action'
require_relative '../helper/ovo_onetrust_helper'

module Fastlane
  module Actions
    class OvoOnetrustScanBuildAction < Action
      def self.run(params)
         Helper::OvoOnetrustHelper.scan_build(
          build_path: params[:build_path],
          client_id: params[:client_id],
          client_secret: params[:client_secret],
          environment: params[:environment],
          webhook_id: params[:webhook_id],
          app_id: params[:app_id],
          app_name: params[:app_name],
          platform: params[:platform]
        )
      end

      def self.description
        "Fastlane plugin to upload mobile app builds to OneTrust and trigger automated SDK scanning."
      end

      def self.authors
        ["Christian Borsato"]
      end

      def self.return_value
        "Returns the OneTrust scan request ID (`requestId`) when the upload/scan request is accepted; returns nil if the request fails."
      end

      def self.details
        # Optional:
        "A Fastlane plugin that uploads iOS and Android build artifacts (IPA/APK) to OneTrust for automated privacy and SDK compliance analysis. It supports configuring authentication and upload parameters via Fastlane options, making it easy to integrate OneTrust scans into CI/CD pipelines. Use it to ensure each release candidate is scanned and tracked as part of your release process."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :build_path,
            env_name: "ONETRUST_BUILD_PATH",
            description: "Path to the build artifact to upload to OneTrust (e.g., /path/to/app.apk, /path/to/app.aab, /path/to/app.ipa)",
            optional: false,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :client_id,
            env_name: "ONETRUST_CLIENT_ID",
            description: "OneTrust OAuth client ID used to obtain an access token (client_credentials)",
            optional: false,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :client_secret,
            env_name: "ONETRUST_CLIENT_SECRET",
            description: "OneTrust OAuth client secret used to obtain an access token (client_credentials)",
            optional: false,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :environment,
            env_name: "ONETRUST_ENVIRONMENT",
            description: "OneTrust environment subdomain used to build the base URL (e.g., 'app-eu', 'app-de', 'app'). Defaults to 'app-eu' if not provided",
            optional: true,
            default_value: "app-eu",
            is_string: true,
            verify_block: lambda do |value|
              v = value.to_s.strip
              UI.user_error!("'environment' must be a non-empty subdomain (e.g., 'app-eu')") if v.empty?
              UI.user_error!("'environment' must not include protocol (https://)") if v.start_with?("http://", "https://")
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :webhook_id,
            env_name: "ONETRUST_WEBHOOK_ID",
            description: "OneTrust Integration webhook identifier used as a path parameter by the upload/scan API",
            optional: false,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :app_id,
            env_name: "ONETRUST_APP_ID",
            description: "Existing OneTrust mobile application ID. Provide this to rescan an existing app; if omitted, the scan will be treated as a new app scan (requires `name`)",
            optional: true,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :app_name,
            env_name: "ONETRUST_APP_NAME",
            description: "Mobile application name (required when creating a new app scan; ignored for rescans)",
            optional: true,
            is_string: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :platform,
            env_name: "ONETRUST_PLATFORM",
            description: "Target platform for the uploaded build. Allowed values: IOS, ANDROID",
            optional: false,
            is_string: true,
            verify_block: lambda do |value|
              allowed = %w[IOS ANDROID]
              normalized = value.to_s.strip.upcase

              unless allowed.include?(normalized)
                UI.user_error!("Invalid value for 'platform': #{value}. Allowed values: #{allowed.join(', ')}")
              end
            end
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
