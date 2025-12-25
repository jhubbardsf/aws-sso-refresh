# aws-sso-refresh

Automatically refresh AWS SSO sessions before they expire, so you never hit "token expired" errors again.

## The Problem

When using AWS SSO (Identity Center), your session tokens expire after a few hours. This means you constantly have to run `aws sso login --profile xyz` when your tokens expire mid-task.

## The Solution

`aws-sso-refresh` runs as a background daemon and proactively refreshes your SSO sessions before they expire. It opens a browser window for re-authentication (which auto-approves if you're already logged in), so your tokens stay fresh.

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

# Install the background daemon (runs every 10 minutes)
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
3. **Refreshes** sessions within 30 minutes of expiring via `aws sso login --sso-session <name>`
4. **Opens a browser** for re-authentication (auto-approves if already logged in)

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

Add this to your `~/.zshrc` or `~/.bashrc` to persist.

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

### Browser doesn't auto-approve

Your Identity Center session may have expired. You'll need to manually approve in the browser once, then subsequent refreshes should be automatic.

## License

MIT - See [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please open an issue or PR on GitHub.
