# aws-sso-refresh

Automatically refresh AWS SSO sessions before they expire, so you never hit "token expired" errors again.

## The Problem

When using AWS SSO (Identity Center), your session tokens expire after a few hours. This means you constantly have to run `aws sso login --profile xyz` when your tokens expire mid-task.

## The Solution

`aws-sso-refresh` runs as a background daemon and proactively refreshes your SSO sessions before they expire. It uses the AWS SSO OIDC API to **silently refresh tokens** without opening a browser. Only when the underlying session has truly expired does it fall back to browser-based re-authentication.

## Installation

### Homebrew (recommended)

```bash
brew install jhubbardsf/aws-sso-refresh/aws-sso-refresh
```

### Manual / curl

```bash
curl -fsSL https://raw.githubusercontent.com/jhubbardsf/aws-sso-refresh/main/install.sh | bash
```

## Requirements

- **macOS** (uses launchd for background scheduling)
- **bash 4.0+** (macOS ships with 3.2 - install with `brew install bash`)
- **jq** (`brew install jq`)
- **AWS CLI v2** (`brew install awscli`)

## Usage

```bash
# Check your SSO session status
aws-sso-refresh status

# Run a refresh check manually
aws-sso-refresh

# Install the background daemon (default: checks every 10 minutes)
aws-sso-refresh install

# View the refresh log
aws-sso-refresh logs

# Remove the background daemon
aws-sso-refresh uninstall

# Show help
aws-sso-refresh help
```

## How It Works

1. **Parses** your `~/.aws/config` to find all `[sso-session]` blocks
2. **Checks** the token cache at `~/.aws/sso/cache/` for expiration times
3. **Silently refreshes** sessions using the SSO OIDC API with the stored refresh token (no browser needed!)
4. **Falls back to browser** only when the refresh token itself has expired (rare - typically after the Identity Center session duration ends)

### Example Status Output

```
AWS SSO Sessions:

  ✓ my-company-sso     5h 23m remaining
  ✓ my-personal-sso    2h 10m remaining

Daemon: running (PID 1234)
Interval: every 10 minutes
Threshold: refresh when < 30m remaining
```

## Configuration

### Refresh Threshold

By default, sessions are refreshed when they have less than 30 minutes remaining. Customize this with:

```bash
export AWS_SSO_REFRESH_THRESHOLD=60  # Refresh when < 60 minutes remaining
```

### Check Interval

By default, the daemon checks sessions every 10 minutes. Customize this with:

```bash
export AWS_SSO_REFRESH_INTERVAL=5  # Check every 5 minutes (min: 1, max: 60)
```

### Session Duration

For accurate "browser re-auth" estimates in status output, set this to match your Identity Center session duration:

```bash
export AWS_SSO_SESSION_DURATION=8  # Default: 8 hours (check with your AWS admin)
```

**Note:** After changing these values, run `aws-sso-refresh uninstall` and `aws-sso-refresh install` to update the daemon configuration.

Add these exports to your `~/.zshrc` or `~/.bashrc` to persist them.

### AWS Config

Your `~/.aws/config` should use the modern `sso-session` format:

```ini
[sso-session my-sso]
sso_start_url = https://my-company.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile dev]
sso_session = my-sso
sso_account_id = 123456789012
sso_role_name = DeveloperAccess
region = us-east-1

[profile prod]
sso_session = my-sso
sso_account_id = 123456789012
sso_role_name = ReadOnlyAccess
region = us-east-1
```

With this setup, you only need to authenticate once per `sso-session`, not per profile!

## Files

| Path | Purpose |
|------|---------|
| `~/.aws/config` | Your AWS configuration with SSO sessions |
| `~/.aws/sso/cache/` | AWS SSO token cache |
| `~/.local/share/aws-sso-refresh/refresh.log` | Daemon log file |
| `~/Library/LaunchAgents/com.aws.sso-refresh.plist` | macOS LaunchAgent |

## Troubleshooting

### "This script requires bash 4.0 or later"

macOS ships with bash 3.2 (from 2007!) due to licensing. Install modern bash:

```bash
brew install bash
```

### Sessions not refreshing

1. Check the daemon is running: `aws-sso-refresh status`
2. Check the logs: `aws-sso-refresh logs`
3. Run manually to test: `aws-sso-refresh`

### Browser keeps opening

If the browser opens frequently for re-authentication, it means the underlying Identity Center session has expired and the refresh token can no longer silently refresh. This typically happens when:

- The session duration in AWS Identity Center is set to a short period (e.g., 1 hour)
- You've been away from your computer for longer than the session duration
- The Identity Center administrator has revoked your session

After re-authenticating in the browser once, subsequent refreshes should be silent again until the session duration expires.

**Note:** The session duration is configured by your AWS administrator in Identity Center settings (typically 8-12 hours by default, up to 7 days).

## License

MIT - See [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please open an issue or PR on GitHub.
