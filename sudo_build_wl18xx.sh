ORG_FILENAME="build_wl18xx.sh"
SUDO_FILENAME="_build_with_sudo.sh"
cp $ORG_FILENAME $SUDO_FILENAME

MAKE_PREFIX="sudo PATH=\$PATH -E "
SUDO_PREFIX="sudo "

makeregex[1]="modules_install"
makeregex[2]="make install"

for i in {1..2}
do
    #echo "Add 'sudo' for $i) ${makeregex[$i]}"
    sed -i "/${makeregex[$i]}/s/^/${MAKE_PREFIX} /" ./$SUDO_FILENAME
done

sudoregex[1]="mkdir"
sudoregex[2]="tar "
sudoregex[3]="cp "
sudoregex[4]="chmod "
sudoregex[5]="rm "

for i in {1..5}
do
    #echo "Add 'sudo' for $i) ${sudoregex[$i]}"
    #sed -i "s/${sudoregex[$i]}/${SUDO_PREFIX} /" ./$SUDO_FILENAME
	sed -i "s/\(${sudoregex[$i]}\)/${SUDO_PREFIX} \1/g" ./$SUDO_FILENAME
done

echo "Finished adding sudo to build script, Running..."

./$SUDO_FILENAME $@
