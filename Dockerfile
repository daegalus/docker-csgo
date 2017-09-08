#
# CSGO Dockerfile
#
# https://hub.docker.com/r/daegalus/docker-csgoserver/
# Forked from https://hub.docker.com/r/austinsaintaubin/docker-csgoserver/
# Also see: https://hub.docker.com/r/johnjelinek/csgoserver/~/dockerfile/

# Pull the base image
FROM ubuntu:17.04
MAINTAINER Yulian Kuncheff <yulian@kuncheff.com>

ENV DEBIAN_FRONTEND noninteractive

#### Variables ####
ENV SERVER_NAME "Counter Strike: Global Offensive - SONM Docker Server"
ENV RCON_PASS rconpass
ENV SERVER_PASS ""
ENV SERVER_LAN 0
ENV SERVER_REGION 0

# Notification Email
# (on|off)
ENV EMAIL_NOTIFICATION off
ENV EMAIL email@example.com

# STEAM LOGIN
ENV STEAM_USER anonymous
ENV STEAM_PASS ""

# Start Variables
# https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Starting_the_Server
# [Game Modes]           gametype    gamemode
# Arms Race                  1            0
# Classic Casual             0            0
# Classic Competitive        0            1
# Demolition                 1            1
# Deathmatch                 1            2
ENV GAME_MODE 0
ENV GAME_TYPE 0
ENV DEFAULT_MAP de_dust2
ENV MAP_GROUP random_classic
ENV MAX_PLAYERS 16
ENV TICK_RATE 64
ENV GAME_PORT 27015
ENV SOURCE_TV_PORT 27020
ENV CLIENT_PORT 27005
ENV GAME_IP 0.0.0.0
ENV UPDATE_ON_START off
ENV GSLT ""

# Optional: Workshop Parameters
# https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators
# To get an authkey visit - http://steamcommunity.com/dev/apikey
ENV AUTH_KEY ""
ENV WS_COLLECTION_ID ""
ENV WS_START_MAP ""

# Expose Ports
EXPOSE $GAME_PORT
EXPOSE $GAME_PORT/udp
EXPOSE $SOURCE_TV_PORT/udp
EXPOSE $CLIENT_PORT/udp
#EXPOSE 1200/udp

# Install Packages / Dependencies
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -qqy wget curl nano tmux mailutils postfix lib32gcc1 \
                         gdb ca-certificates bsdmainutils locales sudo
RUN dpkg --add-architecture i386; sudo apt-get update; sudo apt-get install -qqy python unzip binutils libstdc++6:i386
# Install Postfix Package OR https://hub.docker.com/r/catatnight/postfix/

# FIX ( perl: warning: Please check that your locale settings: )
# http://ubuntuforums.org/showthread.php?t=1346581
RUN locale-gen en_US en_US.UTF-8 hu_HU hu_HU.UTF-8
RUN dpkg-reconfigure locales

# # Cleanup
# RUN apt-get clean && \
#     rm -fr /var/lib/apt/lists/* && \
#     rm -fr /tmp/*

# Create softlink for script (Downloaded Later), this will allow ENTRYPOINT to find the script ( endpoint runs in /root/ )
# RUN ln -s "/home/csgoserver/csgoserver" "/root/csgoserver"

# Create user to run as
# script refuses to run in root, create user
RUN groupadd -r csgoserver && \
        useradd -rm -g csgoserver csgoserver && \
        adduser csgoserver sudo && \
        echo "csgoserver ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER csgoserver
WORKDIR /home/csgoserver

# Volume
RUN chown -R csgoserver:csgoserver /home/csgoserver
# VOLUME ["/home/csgoserver/serverfiles"]

# Download CSGO Server Manager Script
# https://raw.githubusercontent.com/dgibbs64/linuxgameservers/master/CounterStrikeGlobalOffensive/csgoserver
RUN touch .dev-debug
RUN wget -N --no-check-certificate https://gameservermanagers.com/dl/linuxgsm.sh
RUN chmod +x linuxgsm.sh
RUN ./linuxgsm.sh csgoserver

# Run Install Script
RUN ./csgoserver auto-install
RUN wget https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/functions/command_debug.sh -O lgsm/functions/command_debug.sh
RUN chmod +x lgsm/functions/command_debug.sh
RUN cp ./lgsm/config-lgsm/csgoserver/_default.cfg ./lgsm/config-lgsm/csgoserver/common.cfg

# Edit Server Script to hold Docker Environmental Varables
RUN sed -i '/emailnotification=/s/"\([^"]*\)"/"$EMAIL_NOTIFICATION"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/email=/s/"\([^"]*\)"/"$EMAIL"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/steamuser=/s/"\([^"]*\)"/"$STEAM_USER"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/steampass=/s/"\([^"]*\)"/"$STEAM_PASS"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/gamemode=/s/"\([^"]*\)"/"$GAME_MODE"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/gametype=/s/"\([^"]*\)"/"$GAME_TYPE"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/defaultmap=/s/"\([^"]*\)"/"$DEFAULT_MAP"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/mapgroup=/s/"\([^"]*\)"/"$MAP_GROUP"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/maxplayers=/s/"\([^"]*\)"/"$MAX_PLAYERS"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/tickrate=/s/"\([^"]*\)"/"$TICK_RATE"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/port=/s/"\([^"]*\)"/"$GAME_PORT"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/sourcetvport=/s/"\([^"]*\)"/"$SOURCE_TV_PORT"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/clientport=/s/"\([^"]*\)"/"$CLIENT_PORT"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/ip=/s/"\([^"]*\)"/"$GAME_IP"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/updateonstart=/s/"\([^"]*\)"/"$UPDATE_ON_START"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/authkey=/s/"\([^"]*\)"/"$AUTH_KEY"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/ws_collection_id=/s/"\([^"]*\)"/"$WS_COLLECTION_ID"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/ws_start_map=/s/"\([^"]*\)"/"$WS_START_MAP"/' ./lgsm/config-lgsm/csgoserver/common.cfg && \
    sed -i '/gslt=/s/"\([^"]*\)"/"$GSLT"/' ./lgsm/config-lgsm/csgoserver/common.cfg

# Make Start Script
RUN echo '#!/bin/sh' > start.sh && \
    echo '# Docker Start / Run Script' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Override GSLT form command line launch' >> start.sh && \
    echo 'if [ ! -z "$1" ]; then' >> start.sh && \
    echo '  export GSLT=$1' >> start.sh && \
    echo 'fi' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Edit Server Config to hold Docker Environmental Varables' >> start.sh && \
    echo '# ------------------' >> start.sh && \
    echo 'sed -i "/hostname/s/\"\([^\"]*\)\"/\"$SERVER_NAME\"/" serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i "/rcon_password/s/\"\([^\"]*\)\"/\"$RCON_PASS\"/" serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i "/sv_password/s/\"\([^\"]*\)\"/\"$SERVER_PASS\"/" serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i "/sv_lan/s/\"\([^\"]*\)\"/\"$SERVER_LAN\"/" serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i "/sv_region/s/\"\([^\"]*\)\"/\"$SERVER_REGION\"/" serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i '\''s/""/"/g'\'' serverfiles/csgo/cfg/csgoserver.cfg' >> start.sh && \
    echo 'sed -i '\''/gslt=/s/"\([^"]*\)"/"$GSLT"/'\'' ./lgsm/config-lgsm/csgoserver/common.cfg' >>  start.sh && \
    echo '# ------------------' >> start.sh && \
    echo '' >> start.sh && \
    echo '# Script Manager' >> start.sh && \
#     echo './csgoserver auto-install' >> start.sh && \
     echo './csgoserver update' >> start.sh && \
#     echo './csgoserver details' >> start.sh && \
    echo './csgoserver' >> start.sh && \
    echo './csgoserver debug' >> start.sh && \
#    echo 'tmux attach-session' >> start.sh && \
    chmod +x start.sh

# Make Steam 1st time Autentiaction (used to setup cached cradentuals for accounts with 2 factor authentication)
RUN echo '# Steam 1st time Autentiaction (used to setup cached cradentuals for accounts with 2 factor authentication)' > steam-login.sh && \
    echo '# ------------------' >> steam-login.sh && \
    echo 'echo Before running this script you might have to run "./csgoserver install" to download "steamcmd"' >> steam-login.sh && \
    echo 'echo After running this script, edit "csgoserver" script or the "STEAM_PASS" envirmental varable and clear out the password with a space or leave it blank' >> steam-login.sh && \
    echo 'echo =================' >> steam-login.sh && \
    #echo 'echo enter password & 2nd factor' >> start.sh && \
    echo 'steamcmd/./steamcmd.sh +login $STEAM_USER $STEAM_PASS  # Login to steam' >> steam-login.sh && \
    echo 'sed -i "/steampass=/s/\"\([^\"]*\)\"/\"\"/" csgoserver  # CLEAR PASSWORD FIELD in csgoserver script' >> steam-login.sh && \
    chmod +x steam-login.sh

# Remove debug prompt, use Debug to run in foreground to keep the container from dying.
RUN sed -i 71,74d lgsm/functions/command_debug.sh

# Run Start Script
# https://labs.ctl.io/dockerfile-entrypoint-vs-cmd/
# http://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile
# http://kimh.github.io/blog/en/docker/gotchas-in-writing-dockerfile-en/
# http://www.markbetz.net/2014/03/17/docker-run-startup-scripts-then-exit-to-a-shell/
# http://crosbymichael.com/dockerfile-best-practices.html
# https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/
# ENTRYPOINT ["/home/csgoserver/start.sh"]
CMD ["/bin/bash", "-l", "-c", "set -e && /home/csgoserver/start.sh"]
# CMD bash -c 'exec /home/csgoserver/start.sh';'bash'
