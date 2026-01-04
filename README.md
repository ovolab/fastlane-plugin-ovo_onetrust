# Ovo OneTrust - Fastlane Plugin

fastlane plugin to upload mobile app build artifacts (IPA/APK) to OneTrust **Integrations** and trigger a Mobile App Scan (new scan or rescan).

![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)

## Getting started

This plugin uses the OneTrust [Scan Apps via API](https://developer.onetrust.com/onetrust/docs/scan-apps-via-api) workflow available in the **Integrations** module (webhook-based).  
You will need:
- A OneTrust tenant/environment subdomain (e.g. `app-eu`).
- An active “Mobile: Mobile App Scan” integration workflow.
- An OAuth 2.0 Client Credential (client_id / client_secret).
- The workflow webhook ID (from the webhook URL you copy from the workflow builder).

## Installation

Add this line to your project's `fastlane/Pluginfile`:

```ruby
gem "fastlane-plugin-ovo_onetrust"
```

Then run:

```sh
bundle install
```

## Actions

### ovo_onetrust_scan_build

Uploads a build artifact to OneTrust via an Integrations webhook endpoint and triggers a scan/rescan.

#### Parameters

| Key | Env var | Required | Default | Description |
| --- | --- | --- | --- | --- |
| `build_path` | `ONETRUST_BUILD_PATH` | Yes | - | Path to the build artifact to upload to OneTrust (e.g., `/path/to/app.apk`, `/path/to/app.ipa`). |
| `client_id` | `ONETRUST_CLIENT_ID` | Yes | - | OneTrust OAuth client ID used to obtain an access token (`client_credentials`). |
| `client_secret` | `ONETRUST_CLIENT_SECRET` | Yes | - | OneTrust OAuth client secret used to obtain an access token (`client_credentials`). |
| `environment` | `ONETRUST_ENVIRONMENT` | No | `app-eu` | OneTrust environment subdomain used to build the base URL (e.g., `app-eu`, `app-de`, `app`). Must not include protocol (no `https://`). |
| `webhook_id` | `ONETRUST_WEBHOOK_ID` | Yes | - | OneTrust Integration webhook identifier used as a path parameter by the upload/scan API. |
| `app_id` | `ONETRUST_APP_ID` | No | - | Existing OneTrust mobile application ID. Provide this to rescan an existing app; if omitted, the scan will be treated as a new app scan (requires `app_name`). |
| `app_name` | `ONETRUST_APP_NAME` | No* | - | Mobile application name (required when creating a new app scan; ignored for rescans). |
| `platform` | `ONETRUST_PLATFORM` | Yes | - | Target platform for the uploaded build. Allowed values: `IOS`, `ANDROID` (uppercase). |

\* `app_name` is required only when `app_id` is not provided.

#### Return value

Returns the OneTrust scan request identifier (`requestId`) when the request is accepted, or `nil` if the request fails.

## Usage

### Rescan an existing app (recommended)

```ruby
lane :onetrust_rescan do
  request_id = ovo_onetrust_scan_build(
    build_path: "build/onetrust/onetrust.ipa",
    environment: "app-eu",
    client_id: ENV["ONETRUST_CLIENT_ID"],
    client_secret: ENV["ONETRUST_CLIENT_SECRET"],
    webhook_id: ENV["ONETRUST_WEBHOOK_ID"],
    app_id: ENV["ONETRUST_APP_ID"],
    platform: "IOS"
  )

  UI.message("OneTrust requestId: #{request_id}") if request_id
end
```

### New scan (create a new app entry)

```ruby
lane :onetrust_new_scan do
  request_id = ovo_onetrust_scan_build(
    build_path: "build/onetrust/onetrust.ipa",
    environment: "app-eu",
    client_id: ENV["ONETRUST_CLIENT_ID"],
    client_secret: ENV["ONETRUST_CLIENT_SECRET"],
    webhook_id: ENV["ONETRUST_WEBHOOK_ID"],
    app_name: "My App Name",
    platform: "IOS"
  )

  UI.message("OneTrust requestId: #{request_id}") if request_id
end
```

## Notes

- `platform` must be `IOS` or `ANDROID` and must be capitalized.  
- `environment` is used to build the base URL as: `https://{environment}.onetrust.com`.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

- **404 Not Found**:
  - Verify `environment` matches your OneTrust subdomain.
  - Verify `webhook_id` is correct.
  - Ensure you are not appending an extra trailing `/` to the webhook endpoint URL.
- **401 Unauthorized**:
  - Verify `client_id` / `client_secret` and that your Client Credentials are properly configured.
- **Invalid platform**:
  - Use only `IOS` or `ANDROID`.

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## License

MIT