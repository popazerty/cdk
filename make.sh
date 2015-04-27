#!/bin/bash

if [ "$1" == -h ] || [ "$1" == --help ]; then
 echo "Parameter 1: target system (1-36)"
 echo "Parameter 2: kernel (1-5)"
 echo "Parameter 3: debug (y/N)"
 echo "Parameter 4: player (1-2)"
 echo "Parameter 5: Media Framework (1-4)"
 echo "Parameter 6: External LCD support (1-2)"
 echo "Parameter 7: Image (Enigma=1/Neutrino=2) (1-2)"
 echo "Parameter 8: Neutrino variant (1-5)"
 exit
fi

CURDIR=`pwd`
CURRENT_PATH=${CURDIR%/cdk}

CONFIGPARAM=" \
 --enable-maintainer-mode \
 --prefix=$CURRENT_PATH/tufsbox \
 --with-cvsdir=$CURRENT_PATH \
 --with-customizationsdir=$CURRENT_PATH/cdk/custom \
 --with-flashscriptdir=$CURRENT_PATH/flash \
 --with-archivedir=$HOME/Archive \
 --with-maxcachesize=3 \
 --enable-ccache"

##############################################

echo "     _             _ _             _      _                _     _ _    "
echo "    / \  _   _  __| (_) ___  _ __ (_) ___| | _____      __| | __| | |_  "
echo "   / _ \| | | |/ _  | |/ _ \|  _ \| |/ _ \ |/ / __|___ / _  |/ _  | __| "
echo "  / ___ \ |_| | (_| | | (_) | | | | |  __/   <\__ \___| (_| | (_| | |_  "
echo " /_/   \_\__,_|\__,_|_|\___/|_| |_|_|\___|_|\_\___/    \__,_|\__,_|\__| "
echo

##############################################

# config.guess generates different answers for some packages
# Ensure that all packages use the same host by explicitly specifying it.

# First obtain the triplet
AM_VER=`automake --version | awk '{print $NF}' | grep -oEm1 "^[0-9]+.[0-9]+"`
host_alias=`/usr/share/automake-${AM_VER}/config.guess`

# Then undo Suse specific modifications, no harm to other distribution
case `echo ${host_alias} | cut -d '-' -f 1` in
	i?86) VENDOR=pc ;;
	*   ) VENDOR=unknown ;;
esac
host_alias=`echo ${host_alias} | sed -e "s/suse/${VENDOR}/"`

# And add it to the config parameters.
CONFIGPARAM="$CONFIGPARAM --host=$host_alias --build=$host_alias"

##############################################

case $1 in
	[1-9]|1[0-9]|2[0-9]|3[0-9]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo "    1) Kathrein UFS-910"
		echo "    3) Kathrein UFS-912"
		echo "    4) Kathrein UFS-922"
		echo "    5) Topfield TF77X0 HDPVR"
		echo "    6) Fortis HDbox (Fortis FS9000/9200)"
		echo "    7) SpiderBox HL-101"
		echo "    8) Edision Argus vip"
		echo "    9) Cuberevo (IPBOX 9000)"
		echo "   10) Cuberevo mini (IPBOX 900)"
		echo "   11) Cuberevo mini2 (IPBOX 910)"
		echo "   12) Cuberevo 250 (IPBOX 91)"
		echo "   13) Cuberevo 9500HD (7000HD)"
		echo "   14) Cuberevo 2000HD"
		echo "   15) Cuberevo mini_fta (200HD)"
		echo "   16) Homecast 5101"
		echo "   17) Octagon SF1008P (Fortis HS9510)"
		echo "   18) SPARK"
		echo "   19) Atevio AV7500 (Fortis HS8200)"
		echo "   20) SPARK7162"
		echo "   21) IPBOX9900"
		echo "   22) IPBOX99"
		echo "   23) IPBOX55"
		echo "   24) Fortis HS7810A"
		echo "   25) B4Team ADB 5800S"
		echo "   26) Fortis HS7110"
		echo "   27) Atemio AM520"
		echo "   28) Kathrein UFS-913"
		echo "   29) Kathrein UFC-960"
		echo "   30) Vitamin HD5000"
		echo "   31) Atemio AM530"
		echo "   32) SagemCom 88 series"
		echo "   33) Ferguson Ariva @Link 200"
		echo "   34) Fortis HS7119"
		echo "   35) Fortis HS7819"
		echo "   36) Fortis DP7000 (not finished yet)"
		read -p "Select target (1-36)? ";;
esac

case "$REPLY" in
	 1) TARGET="--enable-ufs910";BOXTYPE="--with-boxtype=ufs910";RECEIVER="Kathrein UFS-910";;
	 3) TARGET="--enable-ufs912";BOXTYPE="--with-boxtype=ufs912";RECEIVER="Kathrein UFS-912";;
	 4) TARGET="--enable-ufs922";BOXTYPE="--with-boxtype=ufs922";RECEIVER="Kathrein UFS-922";;
	 5) TARGET="--enable-tf7700";BOXTYPE="--with-boxtype=tf7700";RECEIVER="Topfield TF77X0 HDPVR";;
	 6) TARGET="--enable-fortis_hdbox";BOXTYPE="--with-boxtype=fortis_hdbox";RECEIVER="Fortis FS9000/9200";;
	 7) TARGET="--enable-hl101";BOXTYPE="--with-boxtype=hl101";RECEIVER="SpiderBox HL-101";;
	 8) TARGET="--enable-vip";BOXTYPE="--with-boxtype=vip";RECEIVER="Edision Argus vip";;
	 9) TARGET="--enable-cuberevo";BOXTYPE="--with-boxtype=cuberevo";RECEIVER="Cuberevo (IPBOX 9000)";;
	10) TARGET="--enable-cuberevo_mini";BOXTYPE="--with-boxtype=cuberevo_mini";RECEIVER="Cuberevo mini (IPBOX 900)";;
	11) TARGET="--enable-cuberevo_mini2";BOXTYPE="--with-boxtype=cuberevo_mini2";RECEIVER="Cuberevo mini2 (IPBOX 910)";;
	12) TARGET="--enable-cuberevo_250hd";BOXTYPE="--with-boxtype=cuberevo_250hd";RECEIVER="Cuberevo 250 (IPBOX 91)";;
	13) TARGET="--enable-cuberevo_9500hd";BOXTYPE="--with-boxtype=cuberevo_9500hd";RECEIVER="Cuberevo 9500HD (7000HD)";;
	14) TARGET="--enable-cuberevo_2000hd";BOXTYPE="--with-boxtype=cuberevo_2000hd";RECEIVER="Cuberevo 2000HD";;
	15) TARGET="--enable-cuberevo_mini_fta";BOXTYPE="--with-boxtype=cuberevo_mini_fta";RECEIVER="Cuberevo mini_fta (200HD)";;
	16) TARGET="--enable-homecast5101";BOXTYPE="--with-boxtype=homecast5101";RECEIVER="Homecast 5101";;
	17) TARGET="--enable-octagon1008";BOXTYPE="--with-boxtype=octagon1008";RECEIVER="Fortis HS9510";;
	18) TARGET="--enable-spark";BOXTYPE="--with-boxtype=spark";RECEIVER="Spark";;
	19) TARGET="--enable-atevio7500";BOXTYPE="--with-boxtype=atevio7500";RECEIVER="Fortis HS8200";;
	20) TARGET="--enable-spark7162";BOXTYPE="--with-boxtype=spark7162";RECEIVER="Spark7162";;
	21) TARGET="--enable-ipbox9900";BOXTYPE="--with-boxtype=ipbox9900";RECEIVER="IPBOX 9900";;
	22) TARGET="--enable-ipbox99";BOXTYPE="--with-boxtype=ipbox99";RECEIVER="IPBOX 99";;
	23) TARGET="--enable-ipbox55";BOXTYPE="--with-boxtype=ipbox55";RECEIVER="IPBOX 55";;
	24) TARGET="--enable-hs7810a";BOXTYPE="--with-boxtype=hs7810a";RECEIVER="Fortis HS7810A";;
	25) TARGET="--enable-adb_box";BOXTYPE="--with-boxtype=adb_box";RECEIVER="B4Team ADB 5800S";;
	26) TARGET="--enable-hs7110";BOXTYPE="--with-boxtype=hs7110";RECEIVER="Fortis HS7110";;
	27) TARGET="--enable-atemio520";BOXTYPE="--with-boxtype=atemio520";RECEIVER="Atemio AM520";;
	28) TARGET="--enable-ufs913";BOXTYPE="--with-boxtype=ufs913";RECEIVER="Kathrein UFS-913";;
	29) TARGET="--enable-ufc960";BOXTYPE="--with-boxtype=ufc960";RECEIVER="Kathrein UFC-960";;
	30) TARGET="--enable-vitamin_hd5000";BOXTYPE="--with-boxtype=vitamin_hd5000";RECEIVER="Vitamin HD5000";;
	31) TARGET="--enable-atemio530";BOXTYPE="--with-boxtype=atemio530";RECEIVER="Atemio AM530";;
	32) TARGET="--enable-sagemcom88";BOXTYPE="--with-boxtype=sagemcom88";RECEIVER="SagemCom 88 series";;
	33) TARGET="--enable-arivalink200";BOXTYPE="--with-boxtype=arivalink200";RECEIVER="Ariva@Link 200";;
	34) TARGET="--enable-hs7119";BOXTYPE="--with-boxtype=hs7119";RECEIVER="Fortis HS7119";;
	35) TARGET="--enable-hs7819";BOXTYPE="--with-boxtype=hs7819";RECEIVER="Fortis HS7819";;
	36) TARGET="--enable-fortis_dp7000";BOXTYPE="--with-boxtype=fortis_dp7000";RECEIVER="Fortis DP7000";;
	 *) TARGET="--enable-atevio7500";BOXTYPE="--with-boxtype=atevio7500";;
esac
CONFIGPARAM="$CONFIGPARAM $TARGET $BOXTYPE"

case "$REPLY" in
	8)	REPLY=$3
		echo -e "\nModels:"
		echo " 1) VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo " 2) VIP1 v2 [ single tuner + 2 CI + 1 USB + plug & play tuner (dvb-s2/t/c) ]"
		echo " 3) VIP2 v1 [ twin tuner ]"

		read -p "Select Model (1-3)? "

		case "$REPLY" in
			1) MODEL="--enable-hl101";;
			2) MODEL="--enable-vip1_v2";;
#			3) MODEL="--enable-vip2_v1";;
			*) MODEL="--enable-vip2_v1";;
		esac
		CONFIGPARAM="$CONFIGPARAM $MODEL"
		;;
esac

##############################################

case $2 in
	[1-5])	REPLY=$2;;
	*)	echo -e "\nKernel:"
		echo "   1) STM 24 P0209"
		echo "   2) STM 24 P0211 (recommended)"
		echo "   3) STM 24 P0214 (experimental)"
		echo "   4) STM 24 P0215 (experimental)"
		echo "   5) STM 24 P0217 (experimental)"
		read -p "Select kernel (1-5)? ";;
esac

case "$REPLY" in
	1)  KERNEL="--enable-p0209";KERNELP="P0209";;
	2)  KERNEL="--enable-p0211";KERNELP="P0211";;
	3)  KERNEL="--enable-p0214";KERNELP="P0214";;
	4)  KERNEL="--enable-p0215";KERNELP="P0215";;
	5)  KERNEL="--enable-p0217";KERNELP="P0217";;
	*)  KERNEL="--enable-p0215";KERNELP="P0215";;
esac
CONFIGPARAM="$CONFIGPARAM $KERNEL"

##############################################

if [ "$3" ]; then
	REPLY="$3"
else
	REPLY=N
	read -p "   Activate debug (y/N)? "
fi
[ "$REPLY" == "y" -o "$REPLY" == "Y" ] && CONFIGPARAM="$CONFIGPARAM --enable-debug"
DEBUGR=$REPLY

##############################################

cd ../driver/
echo "# Automatically generated config: don't edit" > .config
echo "#" >> .config
echo "export CONFIG_ZD1211REV_B=y" >> .config
echo "export CONFIG_ZD1211=n" >> .config
cd - &>/dev/null

##############################################

case $4 in
	[1-2])	REPLY=$4;;
	*)	echo -e "\nPlayer:"
		echo "   1) Player 191 (stmfb-3.1_stm24_0102)"
		echo "   2) Player 191 (stmfb-3.1_stm24_0104, recommended)"
		read -p "Select player (1-2)? ";;
esac

PLAYER="--enable-player191 --enable-multicom324"

cd $CURDIR/../driver/include/
if [ -L player2 ]; then
	rm player2
fi

if [ -L stmfb ]; then
	rm stmfb
fi

if [ -L multicom ]; then
	rm multicom
fi

ln -s player2_191 player2
ln -s stmfb-3.1_stm24_0102 stmfb
ln -s ../multicom-3.2.4/include multicom
cd $CURDIR

cd $CURDIR/../driver/
if [ -L player2 ]; then
	rm player2
fi

if [ -L multicom ]; then
	rm multicom
fi

ln -s player2_191 player2
ln -s multicom-3.2.4 multicom
echo "export CONFIG_PLAYER_191=y" >> .config
echo "export CONFIG_MULTICOM324=y" >> .config
cd $CURDIR

cd $CURDIR/../driver/stgfb
if [ -L stmfb ]; then
	rm stmfb
fi

case "$REPLY" in
	1) ln -s stmfb-3.1_stm24_0102 stmfb;PLAYERR="Player 191 (stmfb-3.1_stm24_0102)";;
#	2) ln -s stmfb-3.1_stm24_0104 stmfb;PLAYERR="Player 191 (stmfb-3.1_stm24_0104)";;
	*) ln -s stmfb-3.1_stm24_0104 stmfb;PLAYERR="Player 191 (stmfb-3.1_stm24_0104)";;
esac
cd $CURDIR

##############################################

case $5 in
	[1-4])	REPLY=$5;;
	*)	echo -e "\nMedia Framework:"
		echo "   1) eplayer3"
		echo "   2) gstreamer"
		echo "   3) use built-in (required for Neutrino)"
		echo "   4) gstreamer+eplayer3 (recommended for OpenPLi)"
		read -p "Select media framework (1-4)? ";;
esac

case "$REPLY" in
#	1) MEDIAFW="--enable-eplayer3";MFWORK="eplayer3";;
	2) MEDIAFW="--enable-mediafwgstreamer";MFWORK="gstreamer";;
	3) MEDIAFW="--enable-buildinplayer";MFWORK="built-in";;
	4) MEDIAFW="--enable-eplayer3 --enable-mediafwgstreamer";MFWORK="gstreamer & eplayer3";;
	*) MEDIAFW="--enable-eplayer3";MFWORK="eplayer3";;
esac

##############################################

case $6 in
	[1-2])	REPLY=$6;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1) No external LCD"
		echo "   2) graphlcd for external LCD"
		read -p "Select external LCD support (1-2)? ";;
esac

case "$REPLY" in
	2)	EXTERNAL_LCD="--enable-externallcd";LCDR="Y";;
	*)	EXTERNAL_LCD="";LCDR="N";;
esac

##############################################

case $7 in
	[1-2])	REPLY=$7;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1) Enigma2 (includes WLAN drivers)"
		echo "   2) Neutrino"
		read -p "Select Image to build (1-2)? ";;
esac

case "$REPLY" in
	2)	if [ "$MFWORK" != "built-in" ]; then
			echo "You did not select built-in as the Media Framework."
			echo "This is required for Neutrino."
			echo "Exiting..."
			exit
		fi
		CONFIGPARAM="$CONFIGPARAM --enable-neutrino"
		case $8 in
			[1-5])	REPLY=$8;;
			*)	echo -e "\nWhich neutrino variant do you want to build?"
				echo "   1) neutrino-mp-next"
				echo "   2) neutrino-mp-cst-next"
				echo "   3) neutrino-hd2-exp"
				echo "   4) neutrino-mp-martii-github"
				echo "   5) neutrino-mp-tangos"
				read -p " Select Neutrino variant (1-5)? ";;
		esac
		case "$REPLY" in
			2)	IMAGEN="neutrino-mp-cst-next";;
			3)	IMAGEN="neutrino-hd2-exp";;
			4)	IMAGEN="neutrino-mp-martii-github";;
			5)	IMAGEN="neutrino-mp-tangos";;
			*)	IMAGEN="neutrino-mp-next";;
		esac
		NEUTRINO=$REPLY
		if [ -e lastChoice ]; then
			LASTIMAGE=`cat lastChoice | grep enable-enigma`
			if [ "$LASTIMAGE" ] && [ -d ./.deps ]; then
				make distclean
			fi
		fi;;
	*)	if [ "$MFWORK" == "built-in" ]; then
			echo "You selected built-in as the Media Framework."
			echo "You cannot build Enigma2 with that."
			echo "Exiting..."
			exit
		fi
		CONFIGPARAM="$CONFIGPARAM --enable-enigma2 --enable-wlandriver"
		IMAGEN="enigma2"
		if [ -e lastChoice ]; then
			LASTIMAGE=`cat lastChoice | grep enable-neutrino`
			if [ "$LASTIMAGE" ] && [ -d ./.deps ]; then
				make distclean
			fi
		fi;;
esac

##############################################

CONFIGPARAM="$CONFIGPARAM $PLAYER $MULTICOM $MEDIAFW $EXTERNAL_LCD $IMAGE"

##############################################

echo && \
echo "Performing autogen.sh..." && \
echo "------------------------" && \
./autogen.sh && \
echo && \
echo "Performing configure..." && \
echo "-----------------------" && \
echo && \
./configure $CONFIGPARAM

##############################################

echo $CONFIGPARAM >lastChoice
echo " "
echo "----------------------------------------"
echo "Your build environment is ready :-)"
echo
echo "Selected receiver        : $RECEIVER"
echo "Selected kernel          : stm24 $KERNELP"
echo "Debug option             : $DEBUGR"
echo "Selected player          : $PLAYERR"
echo "Selected media framework : $MFWORK"
echo "External LCD support     : $LCDR"
echo "Image                    : $IMAGEN"
echo "----------------------------------------"
echo
# Create build executable file
cat $CURDIR/remake > $CURDIR/build
if [ "$IMAGEN" == "enigma2" ]; then
  echo "make yaud-enigma2-pli-nightly" >> $CURDIR/build
else
  case "$NEUTRINO" in
    1) echo "make yaud-neutrino-mp-next" >> $CURDIR/build;;
    2) echo "make yaud-neutrino-mp-cst-next" >> $CURDIR/build;;
    3) echo "make yaud-neutrino-hd2-exp" >> $CURDIR/build;;
    4) echo "make yaud-neutrino-mp-martii-github" >> $CURDIR/build;;
    5) echo "make yaud-neutrino-mp-tangos" >> $CURDIR/build;;
    *) exit;;
  esac
fi
chmod 755 $CURDIR/build

read -p "Do you want to start the build now (Y*/n)? "

case "$REPLY" in
  N|n|No|NO|no) echo -e "\nOK. To start the build, execute ./build in this directory.\n"
                exit;;
  *)            $CURDIR/build;;
esac

