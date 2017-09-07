# Counter-Strike: Global Offensive Dedicated Server Dockerfile
This repository contains **Dockerfile** of [Linux Game Server Manager's CS:GO Server](http://gameservermanagers.com/lgsm/csgoserver/) for [Docker](https://www.docker.com/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).
Also see [johnjelinek/csgoserver](https://registry.hub.docker.com/u/johnjelinek/csgoserver/)

### Base Docker Image
* [ubuntu:17.04](https://hub.docker.com/_/ubuntu/)

### Installation
1. Install [Docker](https://www.docker.com/).
2. Download [automated build](https://registry.hub.docker.com/u/daegalus/docker-csgo/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull daegalus/docker-csgo`
   (alternatively, you can build an image from Dockerfile: `docker build -t="austinsaintaubin/docker-csgoserver" github.com/AustinSaintAubin/docker-csgoserver#master`)

### Usage
Once the container starts it will automatically start the server and mind the tmux interface.

You can use the [csgoserver](https://github.com/dgibbs64/linuxgsm/tree/master/CounterStrikeGlobalOffensive) script just like always.
```
./csgoserver COMMAND
```

### Docker Run (Standard)
```
docker run -p 27015:27015/tcp -p 27015:27015/udp -p 27020:27020/udp -p 27005:27005/udp -e EMAIL_NOTIFICATION="off" -e EMAIL="email@example.com" -e STEAM_USER="anonymous" -e STEAM_PASS="" -e GAME_MODE="0" -e GAME_TYPE="0" -e DEFAULT_MAP="de_dust2" -e MAP_GROUP="random_classic" -e MAX_PLAYERS="16" -e TICK_RATE="64" -e GAME_PORT="27015" -e SOURCE_TV_PORT="27020" -e CLIENT_PORT="27005" -e GAME_IP="0.0.0.0" -e UPDATE_ON_START="off" -e AUTH_KEY="" -e WS_COLLECTION_ID="" -e WS_START_MAP="" -e SERVER_NAME="Counter Strike: Global Offensive Docker Server" -e RCON_PASS="rconpass" -e SERVER_PASS="" -e SERVER_LAN="0" -e SERVER_REGION="0" -e GSLT="" --name docker-csgoserver -d austinsaintaubin/docker-csgoserver
```

### Docker Run (Synology NAS)
```
docker run -p 27015:27015/tcp -p 27015:27015/udp -p 27020:27020/udp -p 27005:27005/udp -v /docker/csgoserver:/home/csgoserver/serverfiles -e EMAIL_NOTIFICATION="off" -e EMAIL="email@example.com" -e STEAM_USER="anonymous" -e STEAM_PASS="" -e GAME_MODE="0" -e GAME_TYPE="0" -e DEFAULT_MAP="de_dust2" -e MAP_GROUP="random_classic" -e MAX_PLAYERS="16" -e TICK_RATE="64" -e GAME_PORT="27015" -e SOURCE_TV_PORT="27020" -e CLIENT_PORT="27005" -e GAME_IP="0.0.0.0" -e UPDATE_ON_START="off" -e AUTH_KEY="" -e WS_COLLECTION_ID="" -e WS_START_MAP="" -e SERVER_NAME="Counter Strike: Global Offensive Docker Server" -e RCON_PASS="rconpass" -e SERVER_PASS="" -e SERVER_LAN="0" -e SERVER_REGION="0" --name docker-csgoserver -d austinsaintaubin/docker-csgoserver
```

### Docker Run (Stand Alone)
```
docker run -dt --name csgo -v /var/docker/csgoserver:/home/csgoserver -p 27015:27015/tcp -p 27015:27015/udp --entrypoint /home/csgoserver/serverfiles/srcds_run johnjelinek/csgoserver -game csgo -usercon -strictportbind -ip 0.0.0.0 -port 27015 +clientport 27005 +tv_port 27020 -tickrate 64 +map de_dust2 +servercfgfile csgo-server.cfg -maxplayers_override 16 +mapgroup random_classic +game_mode 0 +game_type 0 +host_workshop_collection  +workshop_start_map  -authkey
```

#### Preparation (Downloading the files onto your volume)
  1. Container should start install automaticly. If you need to start fresh run `./csgoserver install` or `./csgoserver auto-install` in the container.
  4. You can test everything went well with `./csgoserver start` followed by `./csgoserver details`.
  5. If everything looks good, run with the command listed under `Usage`.

Open CS:GO and Browse Community Servers. Open `yourServerIP` to see the result.
