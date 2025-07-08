# Unraid Mover qBittorrent Handler

[![ShellCheck](https://github.com/ggfevans/unraid-qbit-mover/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/ggfevans/unraid-qbit-mover/actions)
[![Version](https://img.shields.io/github/v/release/ggfevans/unraid-qbit-mover?include_prereleases)](https://github.com/ggfevans/unraid-qbit-mover/releases/latest)
[![License](https://img.shields.io/github/license/ggfevans/unraid-qbit-mover)](LICENSE)

Prevent cache drive overflow by gracefully managing qBittorrent during Unraid mover operations.

[Current version: 1.0.0](CHANGELOG.md)

## Why This Exists

Modern Unraid systems use cache pools (SSDs) and array drives (HDDs) in a tiered storage strategy. Shares configured with "Yes" or "Prefer" cache settings write all new data to the cache pool first, providing:

- High-speed write performance for downloads and file operations (crucial for 10Gbe)
- Reduced array drive spin-up, lowering power use and mechanical wear  
- Improved SSD endurance through write coalescing before array transfer
- Better performance for applications reading recent data

A standard media management workflow:
1. qBittorrent downloads to a cache-enabled `/downloads` share
2. Hard-linked copies created in `/media` for Plex/Jellyfin
3. Original files in `/downloads` maintained for seeding

This creates a technical conflict with Unraid's mover process:

1. qBittorrent maintains kernel-level file locks:
   - Write locks on active downloads
   - Read locks on seeding files
2. Mover cannot migrate locked files to array
3. Cache space depletes as locked files accumulate
4. When cache fills:
   - New downloads fail
   - Docker containers cannot write to cache-enabled shares
   - Database writes fail, risking application corruption
   - Real-time media writing (DVR) stops

This script pair solves these issues by:
1. Stopping qBittorrent before mover operations
2. Enabling complete cache-to-array migration of seeding content
3. Automatically resuming seeding from array locations
4. Maintaining hard link integrity
5. Preserving all torrent states

The result:
- Prevents cache overflow
- Maintains download and seeding performance
- Requires no manual intervention

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
