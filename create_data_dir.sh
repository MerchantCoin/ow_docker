# Install starter data
DATADIR="/opt/omniwallet-data"
NAME="omniwallet"
mkdir $DATADIR
cd /tmp
curl -sSO https://www.omniwallet.org/assets/snapshots/current.tar.gz
tar xzf current.tar.gz -C $DATADIR
cp -r $DATADIR/www/* $DATADIR/
rm $DATADIR/revision.json
chown -R $NAME:$NAME $DATADIR
rm /tmp/current.tar.gz
