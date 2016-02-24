#!/usr/bin/env bash

PLUGINFILE=/tmp/pluginlist.txt
PDIR="/opt/sonarqube/extensions/plugins"

#rm -rf "${PDIR}/*"

rm -f $PLUGINFILE
[ ! -z "$PLUGINLIST"     ] \
  && echo "PLUGINLIST IN ENV VARIABLE FOUND." \
  && echo "$PLUGINLIST" | tr ";" "\n" >> $PLUGINFILE

[ ! -z "$PLUGINLIST_URL" ] \
  && echo "PLUGINLIST URL FOUND." \
  && curl -LfSs $PLUGINLIST_URL >> $PLUGINFILE

if [ -f $PLUGINFILE ]; then
  echo -e "\n\nPLUGINFILE FOUND. CONTENTS:\n\n --- pluginfile ---"
  cat $PLUGINFILE
  echo -e " --- /pluginfile ---\n\nSTARTING DOWNLOAD.\n"
  cat $PLUGINFILE | grep -Ev '^ *(#.*)?$' | while read PLUGLINE ; do
    PLUGLINE=$(echo $PLUGLINE | sed -re 's/^ +//g' -e 's/ +/ /g' -e 's/ +$//g')
    PLUGINURL=$(echo $PLUGLINE | cut -d " " -f 1)
    FILENAME=$(echo $PLUGLINE | awk '{print $2}' )
    if [ -z "$FILENAME" ] ; then
      echo "NEED FILENAME FOR PLUGLINE: $PLUGLINE"
      exit -1
    fi
    if ! $(echo $FILENAME | grep -ie '.jar$' > /dev/null) ; then
      FILENAME="${FILENAME}.jar"
    fi
    curl -LfSs -o "${PDIR}/$FILENAME" $PLUGINURL
    if [ ! "$?" = "0" ]; then
      echo "ERROR: downloading plugin:"
      echo "       URL:     $PLUGINURL"
      echo "       TARGET:  ${PDIR}/$FILENAME"
      echo "Aborting."
      exit -2
    else
      echo "DOWNLOADED PLUGIN: $FILENAME"
    fi
  done
  echo -e "\nPLUGIN DOWNLOAD FINISHED. STARTING SONARQUBE.\n"
fi
exec /opt/sonarqube/bin/run.sh
