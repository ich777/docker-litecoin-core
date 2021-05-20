#!/bin/bash
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/runtime-litecoin
export XAUTHORITY=${DATA_DIR}/.Xauthority

CUR_V="$(${DATA_DIR}/Litecoin/bin/litecoin-cli --version 2>/dev/null | grep "Litecoin Core RPC client version v" | awk '{print $6}')"
LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/Litecoin | grep LATEST | cut -d '=' -f2)"

if [ -z "$LAT_V" ]; then
	if [ ! -z "${CUR_V##*v}" ]; then
		echo "---Can't get latest version of Litecoin-Core falling back to $CUR_V---"
		LAT_V="${CUR_V##*v}"
	else
		echo "---Something went wrong, can't get latest version of Litecoin-Core, putting container into sleep mode---"
		sleep infinity
	fi
fi

echo "---Version Check---"
if [ -z "${CUR_V##*v}" ]; then
	echo "---Litecoin-Core not installed, installing---"
    cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Litecoin-Core-${LAT_V}.tar.gz https://download.litecoin.org/litecoin-${LAT_V}/linux/litecoin-${LAT_V}-x86_64-linux-gnu.tar.gz ; then
    	echo "---Sucessfully downloaded Litecoin-Core---"
    else
    	echo "---Something went wrong, can't download Litecoin-Core, putting container in sleep mode---"
        sleep infinity
    fi
    mkdir -p ${DATA_DIR}/Litecoin
	tar -C ${DATA_DIR}/Litecoin --strip-components=1 -xf Litecoin-Core-${LAT_V}.tar.gz
	rm -R ${DATA_DIR}/Litecoin-Core-${LAT_V}.tar.gz
elif [ "${CUR_V##*v}" != "$LAT_V" ]; then
	echo "---Version missmatch, installed $CUR_V, downloading and installing latest v$LAT_V...---"
    cd ${DATA_DIR}
	rm -rf ${DATA_DIR}/Litecoin
    mkdir -p ${DATA_DIR}/Litecoin
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Litecoin-Core-${LAT_V}.tar.gz https://download.litecoin.org/litecoin-${LAT_V}/linux/litecoin-${LAT_V}-x86_64-linux-gnu.tar.gz ; then
    	echo "---Sucessfully downloaded Litecoin-Core---"
    else
    	echo "---Something went wrong, can't download Litecoin-Core, putting container in sleep mode---"
        sleep infinity
    fi
    mkdir -p ${DATA_DIR}/Litecoin
	tar -C ${DATA_DIR}/Litecoin --strip-components=1 -xf Litecoin-Core-${LAT_V}.tar.gz
	rm -R ${DATA_DIR}/Litecoin-Core-${LAT_V}.tar.gz
elif [ "${CUR_V##*v}" == "$LAT_V" ]; then
	echo "---Litecoin-Core $CUR_V up-to-date---"
fi

echo "---Preparing Server---"
if [ ! -d ${DATA_DIR}/.litecoin ]; then
	mkdir -p ${DATA_DIR}/.litecoin
fi
if [ ! -d /tmp/runtime-litecoin ]; then
	mkdir -p /tmp/runtime-litecoin
	chmod -R 0700 /tmp/runtime-litecoin
fi
echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
	echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
	echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
    CUSTOM_RES_H=768
fi
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
 rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
 if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Litecoin-Core---"
cd ${DATA_DIR}
${DATA_DIR}/Litecoin/bin/litecoin-qt -datadir=${DATA_DIR}/.litecoin ${START_PARAMS}