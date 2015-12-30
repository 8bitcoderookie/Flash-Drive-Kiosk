#!/bin/bash
#
# Copyright 2014 Michael Rundel
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:
# This script makes a dd image (.img) file of DEVICE_NAME
# and saves it to the current directory
#
# Version 1.0

BACKTITLE="Image von BRG4 Master-Lernstick erstellen"
DEVICE_NAME="sdc"
IMAGE_DIRECTORY="./"
IMAGE_EXTENSION=".img"

dialog --title " Master einstecken " --backtitle "$BACKTITLE" --msgbox "\nStecke den Master-USB-Stick ein und\ndrücke die <Eingabetaste>." 8 39
DEVICE_LABEL=$( find /dev/disk/by-id/ -lname "*$DEVICE_NAME" | cut -c 17- )
if [[ -n $DEVICE_LABEL ]]
then
	dialog --colors --title " Bestätigung Quelle" --backtitle "$BACKTITLE" --yesno "\nDer Wechseldatenträger\n\Zb$DEVICE_LABEL\Zn\nwurde gefunden.\n\nSoll davon eine Image Datei gemacht werden?" 11 60
	RESPOSE=$?
	if [ $RESPOSE = 0 ]
	then
		exec 3>&1
		NAME=$( dialog --title " Dateiname wählen " --backtitle "$BACKTITLE" --inputbox "\nBitte Dateiname für das Image eingeben\n(ohne Endung .img)\n " 11 50 2>&1 1>&3);
		EXITCODE=$?;
		exec 3>&-;
		if [ "$EXITCODE" = "0" ]
		then
			if [[ "$NAME" != *.img ]]
	    	NAME="$NAME.img"
			fi
			(pv -n /dev/$DEVICE_NAME | sudo dd of="$IMAGE_DIRECTORY$NAME" bs=4096 conv=notrunc,noerror) 2>&1 | dialog --title " Imagedatei erstellen " --backtitle "$BACKTITLE" --gauge "\nImage von Master-USB-Stick wird erstellt.\nBitte warten..." 11 70 0
			dialog --title " Fertig! " --msgbox "\nName: $NAME" 6 60
			dialog --title " Fertig! " --msgbox "\nKopiervorgang erfolgreich beendet." 7 38
		fi
	fi
else
	dialog --title " Kein USB-Stick " --backtitle "$BACKTITLE" --msgbox "\nEs konnte kein angesteckter USB-Stick gefunden werden.\nBitte versuche es bitte noch einmal..." 8 58
fi
