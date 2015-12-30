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
# This script copies an image (.img) to a flashdrive (checking required space)
# image files are expected to be in the same directory as scripts.
# if there are more than one image file a menu is displayed, where the user
# can select the desired image for his flashdrive.
# NOTE: script runs in an endless loop since it is intended for kiosk use.
#
# Version 1.0
# Version 1.1 added image select menu for multiple images

BACKTITLE="BRG4 Lernstick erstellen"
DEVICE_NAME="sdc"
ARR_FILENAMES=( $( ls -t -1 ./*.img ) )

while true
do
	dialog --title " USB-Stick einstecken " --backtitle "$BACKTITLE" --msgbox "\nStecke einen USB-Stick ein und drücke die <Eingabetaste>." 7 61
	DEVICE_LABEL=$( find /dev/disk/by-id/ -lname "*$DEVICE_NAME" | cut -c 17- )
	if [[ -n $DEVICE_LABEL ]]
	then
		if [ ${#ARR_FILENAMES[*]} -eq 0 ]
	    echo "Auf der Lernstick Station befindet sich kein Abbild eines Lernsticks.\nBitte Melde diesen Fehler im Sekretariat."
		else
			if (( ${#ARR_FILENAMES[*]} > 1 ))
			then
				ARR_TAG_ITEM=( $( ls -t -1 ./*.img | xargs -n1 basename | cat -n ) )
				exec 3>&1
				SELECTEDMENUITEM=$( dialog --title " Image auswählen " --backtitle "$BACKTITLE" --menu "\nVerwende die <Pfeiltasten> um einen Eintrag zu wählen\nund die <Eingabetaste> um deine Wahl zu bestätigen.\n " 15 70 5 "${ARR_TAG_ITEM[@]}" 2>&1 1>&3);
				EXITCODE=$?;
				exec 3>&-;
				if [ "$EXITCODE" = "0" ]
				then
					IMAGE_PATH=${ARR_FILENAMES[(($SELECTEDMENUITEM-1))]}
				fi
			else
				IMAGE_PATH=${ARR_FILENAMES[0]}
			fi
			BYTE_SIZE_DEVICE=$( echo $(( $(cat /sys/block/$DEVICE_NAME/size) * $(cat /sys/block/$DEVICE_NAME/queue/logical_block_size) )) )
			BYTE_SIZE_IMAGE=$( stat -c%s "$IMAGE_PATH" )
			if [ $BYTE_SIZE_DEVICE -lt $BYTE_SIZE_IMAGE ]
			then
				dialog --colors --title " Zu wenig Speicherplatz " --backtitle "$BACKTITLE" --msgbox "\nDer Wechseldatenträger\n\Zb$DEVICE_LABEL\Zn\nhat ZU WENIG SPEICHERPLATZ!\nUSB-Stick: $BYTE_SIZE_DEVICE Bytes; benötigt: $BYTE_SIZE_IMAGE Bytes\n\nBitte verwende einen USB-Stick mit mehr Speicherplatz..." 12 60
			else
				dialog --colors --title " Bestätigung " --backtitle "$BACKTITLE" --yesno "\nSoll aus dem Wechseldatenträger\n\Zb$DEVICE_LABEL\Zn\nein BRG4 Lernstick gemacht werden?\n(HINWEIS: ALLE DATEN DES USB-STICKS WERDEN GELÖSCHT!)" 10 60
				EXITCODE=$?
				if [ $EXITCODE = 0 ]
				then
					for PARTITION in /dev/$DEVICE_NAME*
					do
						sudo umount $PARTITION
					done
					(pv -n $IMAGE_PATH | sudo dd of=/dev/$DEVICE_NAME) 2>&1 | dialog --title "Daten kopieren" --backtitle "$BACKTITLE" --gauge "Kopiere $IMAGE_PATH auf USB-Stick.\nBitte warten..." 10 70 0
					dialog --title " Kopiervorgang abgeschlossen " --backtitle "$BACKTITLE" --msgbox "\nEntferne bitte den fertigen BRG4 Lernstick." 7 47
				fi
			fi
		fi
	else
		dialog --title " Kein USB-Stick " --backtitle "$BACKTITLE" --msgbox "\nEs konnte kein angesteckter USB-Stick gefunden werden.\nBitte versuche es bitte noch einmal." 8 58
	fi
done
