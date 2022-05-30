
# qbittorrent-docker-ratio-faker
POC modded qbittorrent+libtorrent to fake uploaded ratio data

## TL;DR
```docker run -e LIB_TORRENT_UPLOAD_MULT=5.0 -it --rm ```


## Configuration
configuration is done via environment variable (the `-e NAME=Value` thing passed to docker run/start).  
| Name | Description | example |
|-------------------------|---| -- |
| LIB_TORRENT_UPLOAD_MULT        |  uploaded byte count multiplier  | LIB_TORRENT_UPLOAD_MULT=5.0 |




## Links
- [my modded libtorrent repo](https://github.com/maxisoft/libtorrent)
- [qbittorrent base image](https://github.com/linuxserver/docker-qbittorrent/packages)
