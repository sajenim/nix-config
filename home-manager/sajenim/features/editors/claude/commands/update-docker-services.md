Update all Docker service images on viridian to their latest pinned release versions.

For each service, look up the latest release version from the official sources and update the
image tag to the specific version number (not "latest").

Services to update:
- Jellyfin (jellyfin/jellyfin)
- Lidarr (ghcr.io/hotio/lidarr)
- Prowlarr (ghcr.io/hotio/prowlarr)
- qBittorrent (ghcr.io/hotio/qbittorrent)
- Radarr (ghcr.io/hotio/radarr)
- Sonarr (ghcr.io/hotio/sonarr)
- OpenGist (ghcr.io/thomiceli/opengist)

Use web search to find the latest release versions, then update the image tags in the
configuration files located in nixos/viridian/multimedia/ and nixos/viridian/services/.
