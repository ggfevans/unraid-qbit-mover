# Unraid Mover qBittorrent Handler

[![ShellCheck](https://github.com/ggfevans/unraid-qbit-mover/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ggfevans/unraid-qbit-mover/actions)
[![Version](https://img.shields.io/github/v/release/ggfevans/unraid-qbit-mover?include_prereleases)](https://github.com/ggfevans/unraid-qbit-mover/releases/latest)
[![License](https://img.shields.io/github/license/ggfevans/unraid-qbit-mover)](LICENSE)

Prevent cache drive overflow by gracefully managing qBittorrent during Unraid mover operations.

[Current version: 1.0.0](CHANGELOG.md)

## Why This Exists

When qBittorrent (or your BitTorrent client of choice) downloads files to your cache drive, it maintains active file locks. These locks can prevent the Unraid mover from clearing completed downloads from your cache drive, leading to:

- Cache drive filling up unexpectedly
- Mover operations failing silently
- Potential download interruptions
- Cache pool space issues

This script pair solves these issues by:
1. Gracefully stopping qBittorrent before mover runs
2. Allowing mover to clear the cache drive
3. Automatically restarting qBittorrent when complete

## Quick Start

1. SSH into your Unraid server and run:
   ```bash
   mkdir -p /mnt/user/data/scripts/qbit
   cd /mnt/user/data/scripts/qbit
   wget https://raw.githubusercontent.com/ggfevans/unraid-qbit-mover/main/{mover-stop-qbit.sh,mover-start-qbit.sh}
   chmod +x mover-*.sh
   ```

2. In Unraid web UI, go to Settings → Scheduler → Mover Tuning and set:
   - Before mover: `/mnt/user/data/scripts/qbit/mover-stop-qbit.sh`
   - After mover: `/mnt/user/data/scripts/qbit/mover-start-qbit.sh`

## Features

✨ Graceful container handling
📝 Detailed logging
🔄 Automatic retries
⚡ Signal handling
🔍 Safety checks
🔒 MIT Licensed
✅ ShellCheck validated

## Configuration

Edit these variables in both scripts if needed:

```bash
readonly CONTAINER_NAME="qbittorrent"  # Your container name
readonly LOG_DIR="/var/log/mover"      # Log directory
readonly TIMEOUT=30                    # Stop timeout (seconds)
readonly MAX_RETRIES=3                # Start retry attempts
readonly RETRY_DELAY=5                # Seconds between retries
```

Logs are written to `/var/log/mover/mover-{stop,start}-qbit.log`

## Requirements

- Unraid 6.8.0+
- qBittorrent Docker container
- Container named "qbittorrent" (or update CONTAINER_NAME)

## Troubleshooting

Common issues and solutions:

1. **Container not stopping**: Check TIMEOUT setting in mover-stop-qbit.sh
2. **Container not starting**: Verify MAX_RETRIES and RETRY_DELAY in mover-start-qbit.sh
3. **Permission denied**: Ensure scripts are executable (`chmod +x`)
4. **Logs not writing**: Check LOG_DIR permissions

See logs at `/var/log/mover/mover-{stop,start}-qbit.log` for details.

## Development

- [Contributing guidelines](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

### Local Development

1. Clone repository
2. Install ShellCheck
3. Make changes
4. Run ShellCheck locally:
   ```bash
   shellcheck mover-*.sh
   ```

## Testing

This project is tested using:
- ShellCheck for static analysis
- Manual testing on Unraid 6.8.0+
- Docker container testing

To run tests locally:
```bash
shellcheck mover-*.sh
```

## Security

Scripts run with standard Docker permissions. No root access required beyond normal Docker operations.

## Support

- [Open an issue](https://github.com/ggfevans/unraid-qbit-mover/issues)
- [Unraid Forums](https://forums.unraid.net/)

## License

MIT License - See [LICENSE](LICENSE)

## Contributing

PRs welcome! Fork → Branch → Change → PR

## Authors

[@ggfevans](https://github.com/ggfevans) - Initial work