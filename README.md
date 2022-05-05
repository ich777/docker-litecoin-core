# Litecoin Core in Docker optimized for Unraid
Litecoin is a peer-to-peer Internet currency that enables instant, near-zero cost payments to anyone in the world. Litecoin is an open source, global payment network that is fully decentralized without any central authorities. Mathematics secures the network and empowers individuals to control their own finances. Litecoin features faster transaction confirmation times and improved storage efficiency than the leading math-based currency. With substantial industry support, trade volume and liquidity, Litecoin is a proven medium of commerce complementary to Bitcoin.

You can find the full source code here: https://github.com/litecoin-project/litecoin

ATTENTION: Please keep in mind that your wallet is stored in the created folder in your appdata directory//.litecoin/wallet.dat - I strongly recommend you to backup this file on a regular basis!

IMPORT: If you are already using Litecoin Core you can import your existing wallet by placing the WALLETFILE in the appdata directory for litecoin/.litecoin/wallet.dat and then choose to use a existing wallet.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Please keep in mind that your wallet is stored there and I strongly recommend you to backup that path (the wallet is stored in your Litecoin appdata directory//.litecoin/wallet.dat). | /litecoin |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |

## Run example
```
docker run --name Litecoin-Core -d \
	-p 8080:8080 \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--volume /path/to/litecoin:/litecoin \
    --restart=unless-stopped \
	ich777/litecoin-core
```
### Webgui address: http://[IP]:[PORT:8080]/vnc.html?autoconnect=true

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/