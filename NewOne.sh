#!bin/bash
echo "   Welcome to use This Tool "
echo ""
echo "    Power by Neodev Team"

echo -n "Checking environment... "
echo ""
if cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/os-release | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/os-release | grep -Eqi "debian"; then
    release="debian"
else
    echo "==============="
    echo "Not supported"
    echo "==============="
    exit
fi
clear

echo "Do you want to check the require dependencies ? It is recommned to check at firs time .(y/n)"
check="y"
if [ $check = "y" ] ; then
echo -n "Checking dependencies... "
echo ""
echo "Preparing proper environment.." 
apt update
apt install -y python-dev python3 build-essential libssl-dev libffi-dev python3-dev python3-pip simg2img liblz4-tool 
clear
echo "Preparing proper library.."
for pip3 in setuptools wheel progress clint simple-crypt aes click requests
do
echo ""
pip3 install $pip3
done
clear
echo -n "Checking done. "
echo ""
else
echo -n "Skip dependencies Check."
echo ""
fi

echo "Downloading Sam-get tool.."
wget -q -N --no-check-certificate https://raw.githubusercontent.com/neodevpro/sam-get/master/sam-get.zip
unzip -q sam-get.zip
clear
 
echo "Enter Model and Region (Example:SM-N9500 CHC): "
model="SM-G9550 CHC"
echo ""
info=$(python3 main.py checkupdate $model)
name=${model:0:8}"_"${model:9:3}"_"${info:0:13}
python3 main.py download $info $model $name.enc4
python3 main.py decrypt4 $info $model $name.enc4 $name.zip
rm -rf $name.enc4 main.py sam-get.zip samcatcher
echo "You have download the firmware successfully "
echo ""
echo "Samsung Odin Firmware Fame : $name.zip "
clear

echo "Now Uploading $name.zip "
echo ""

HOST='neodev.ddns.net'
USER='plmh'
PASSWD='hellyzlp'

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
mkdir /Files/Samsung/Firmware/$name
cd /Files/Samsung/Firmware/$name
put $name.zip
quit
END_SCRIPT

if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"* || "$model" == *"SM-N9500"* ]] ; then
echo "Now Deploying firmware "
echo ""
unzip -q -o $name.zip AP*.tar.md5 
tar -xf AP*.tar.md5 system.img.ext4.lz4

rm -rf AP*.tar.md5 

lz4 -d -q system.img.ext4.lz4 system.img.ext4

rm -rf system.img.ext4.lz4

mkdir system

mkdir tempsystem

simg2img system.img.ext4 system.img

rm -rf system.img.ext4

mount -t ext4 -o loop system.img tempsystem/

cp -arf tempsystem/* system/

umount tempsystem

rm -rf tempsystem system.img

unzip -q -o $name.zip CSC*.tar.md5 

tar -xf CSC*.tar.md5 cache.img.ext4.lz4

rm -rf CSC*.tar.md5

lz4 -d -q cache.img.ext4.lz4 cache.img.ext4

rm -rf cache.img.ext4.lz4

simg2img cache.img.ext4 cache.img

rm -rf cache.img.ext4

mkdir cache

mount -t ext4 -o loop cache.img cache/

unzip -q cache/recovery/sec_csc.zip -d csc

cp -arf csc/system/* system/

umount cache

rm -rf cache csc cache.img


wget -q https://raw.githubusercontent.com/neodevpro/resources/master/8sbasefix.zip

unzip -q 8sbasefix.zip

rm -rf 8sbasefix.zip

cp -arf 8sbasefix/system/. system/

cp -arf 8sbasefix/fstab.qcom system/vendor/etc

rm -rf 8sbasefix
if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"* ]] ; then
wget -q https://raw.githubusercontent.com/neodevpro/resources/master/s8sflash.zip
unzip -q s8sflash.zip
rm -rf s8sflash.zip
else
wget -q https://raw.githubusercontent.com/neodevpro/resources/master/n8sflash.zip
unzip -q n8sflash.zip
rm -rf n8sflash.zip
fi

mkdir rootzip

wget -q -O rootzip/Magisk.zip https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip

unzip -q -o rootzip/Magisk.zip common/magisk.apk
mkdir system/app/MagiskManager
cp -arf common/magisk.apk ./system/app/MagiskManager
rm -rf common

if [[ "$model" == *"SM-G9500"* ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9500.img
elif [[ "$model" == *"SM-G9550"* ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9550.img
elif [[ "$model" == *"SM-N9500"* ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/N9500.img
fi

sed -i "s/ro.config.tima=1/ro.config.tima=0/g" system/build.prop
sed -i "s/ro.config.timaversion_info=Knox3.2_../ro.config.timaversion_info=0/g" system/build.prop
sed -i "s/ro.config.iccc_version=3.0/ro.config.iccc_version=iccc_disabled/g" system/build.prop
sed -i "s/ro.config.timaversion=3.0/ro.config.timaversion=0/g" system/build.prop

sed -i "s/ro.config.dmverity=A/ro.config.dmverity=false/g" system/build.prop
sed -i "s/ro.config.kap_default_on=true/ro.config.kap_default_on=false/g" system/build.prop
sed -i "s/ro.config.kap=true/ro.config.kap=false/g" system/build.prop

wget -q https://raw.githubusercontent.com/neodevpro/resources/master/add_to_buildprop.sh

bash ./add_to_buildprop.sh

wget -q https://raw.githubusercontent.com/neodevpro/resources/master/csc_tweaks.sh

sh ./csc_tweaks.sh

rm -rf csc_tweaks.sh add_to_buildprop.sh

rm -rf system/recovery-from-boot.p
rm -rf system/app/BBCAgent
rm -rf system/app/KnoxAttestationAgent
rm -rf system/app/MDMApp
rm -rf system/app/SecurityLogAgent
rm -rf system/app/SecurityProviderSEC
rm -rf system/app/UniversalMDMClient
rm -rf system/container
rm -rf system/etc/permissions/knoxsdk_edm.xml
rm -rf system/etc/permissions/knoxsdk_mdm.xml
rm -rf system/etc/recovery-resource.dat
rm -rf system/priv-app/DiagMonAgent
rm -rf system/priv-app/KLMSAgent
rm -rf system/priv-app/KnoxCore
rm -rf system/priv-app/knoxvpnproxyhandler
rm -rf system/priv-app/Rlc
rm -rf system/priv-app/SamsungPayStub
rm -rf system/priv-app/SecureFolder
rm -rf system/priv-app/SPDClient
rm -rf system/priv-app/TeeService

rm -rf system/lib/libvkservice
rm -rf system/lib64/libvkservice

rm -rf system/lib/libvkjni
rm -rf system/lib64/libvkjni

rm -rf system/etc/init/bootchecker.rc
rm -rf system/secure_storage_daemon_system.rc

rm -rf system/lib/liboemcrypto

cp -arf system/preload/GoogleCalendarSyncAdapter ./system/app
cp -arf system/preload/GoogleContactsSyncAdapter ./system/app
cp -arf system/preload/MateAgent ./system/app
cp -arf system/preload/MtpShareApp ./system/app
cp -arf system/preload/ScreenRecorder ./system/app
cp -arf system/preload/Weather_SEP10.1 ./system/app
cp -arf system/preload/WechatPluginMiniApp ./system/app

rm -rf system/preload
rm -rf system/preloadFotaOnly

zip -r -q -y ${model:0:8}_StockMod.zip META-INF rootzip system boot.img

rm -rf META-INF rootzip boot.img system

echo "You have port the rom successfully " 
echo ""
echo "Custom Stock Rom Name : ${model:0:8}_StockMod.zip "
echo ""


echo "Now Uploading ${model:0:8}_StockMod.zip "
echo ""

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
mkdir /Files/Samsung/Firmware/$name/StockMod
cd /Files/Samsung/Firmware/$name/StockMod
put ${model:0:8}_StockMod.zip
quit
END_SCRIPT

else
echo "Currently Not supported Stock deploy."
echo ""
fi


exit 0

