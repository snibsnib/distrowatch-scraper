#!/bin/bash
echo "Getting Active Distros"

date=$(date +%d.%m.%Y)
distro_list="list.txt"
distro_list_csv="list.csv"
working="tmp"

#Make folder for scan
mkdir -p scan_$date
cd scan_$date

#cleanup old files
rm *.* 2> /dev/null

#grab list of distros(text for scraper loop, csv for sqlite)
wget -q -O - distrowatch.com/search.php?status=Active | grep -A 1  "<option selected value=\"\">Select Distribution</option>" | tr "<" '\n' | grep '"[^"]*"' | cut -c 15- | sed 's/["].*//' | tail -n +2 > $distro_list
cat $distro_list | tr '\n' , > $distro_list_csv

#count distros
q=$(cat $distro_list | wc -l)
echo "Scanning $q Distros"

#create CSV
touch output.csv
echo "id,name,basedon,origin,arch,desktop,packagemanager,releasemodel,init,kernel_ver,xorg_ver,wayland_ver,gcc_ver,clang_ver,category,status,rank,desc,web,lastv,lastdate" >> output.csv

#Scraper Loop
cat $distro_list | while read line;do

	i=$(($i+1))
	distro=$(echo $line | tr -d ' ')
	echo "================================================================================"
	echo "[$i/$q] $distro"
	echo ""

	
	wget -q -O "$distro.$working" https://distrowatch.com/table.php?distribution=$distro

	id=$distro
	name=$(cat "$distro.$working" | head -n 2 | tail -n 1 | cut -c 25- | cut -d '<' -f 1)
	
	arch=$(cat "$distro.$working" | grep "Architecture" | awk -F"Architecture:</b>" '{ print $2 }' | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | tr ',' ' ')
	basedon=$(cat "$distro.$working" | grep "Based on" | awk -F"Based on:</b>" '{ print $2 }' | awk -F"<br />" '{ print $1 }' | sed -n '/^$/!{s/<[^>]*>//g;p;}' | tr ',' ' ')
	category=$(cat "$distro.$working" | grep "Category" | awk -F"Category:</b>" '{ print $2 }' | html2text | awk -F"*" '{ print $1 }' | sed '/^\s*$/d' | tr -d '\n' | sed 's/search.php/distrowatch.com/g' | cut -d ':' -f 1 | rev | cut -c 7- | rev | tr ',' ' ')
	clang_ver=$(cat "$distro.$working" | grep ">clang</a>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	desc=$(cat "$distro.$working" | grep -B1 -m1 "<br /><br />" | awk -F"<br /><br />" '{ print $1 }' | sed '/^\s*$/d' | tr ',' ' ' | html2text | tr -d '\n')
	desktop=$(cat "$distro.$working" | grep "Desktop:" | head -n 1 | awk -F"Desktop:</b>" '{ print $2 }' | awk -F"<br />" '{ print $1 }' | sed -n '/^$/!{s/<[^>]*>//g;p;}' | cut -c 2- | tr ',' ' ')
	gcc_ver=$(cat "$distro.$working" | grep ">gcc</a>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	init=$(cat "$distro.$working" | grep "<th>Init Software</th>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	kernel_ver=$(cat "$distro.$working" | grep 'href="https://www.kernel.org/">linux</a>' -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	lastdate=$(cat "$distro.$working"	| grep "<th>Release Date</th>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	lastv=$(cat "$distro.$working" | grep "<td class=\"TablesInvert" -m1 | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | tr ',' ' ')
	origin=$(cat "$distro.$working" | grep "Origin" | awk -F"Origin:</b>" '{ print $2 }' | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | tr ',' ' ')
	packagemanager=$(cat "$distro.$working" | grep "<th>Package Management</th>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	rank=$(cat "$distro.$working" | grep "popularity" | awk -F"Popularity:</b>" '{ print $2 }' | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | tr ',' ' ' | tr -d '\n' | awk -F" " '{ print $1 }')
	#reader_rating=
	releasemodel=$(cat "$distro.$working" | grep "<th>Release Model</th>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	status=$(cat "$distro.$working" | grep "Status" | awk -F"Status:</b>" '{ print $2 }' | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }' | tr ',' ' ')
	xorg_ver=$(cat "$distro.$working" | grep ">xorg-server</a>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	wayland_ver=$(cat "$distro.$working" | grep ">wayland</a>" -A 1 -m 1 | tail -n 1 | awk -F ">" '{ print $2 }' | awk -F "<" '{print $1}' | tr ',' ' ')
	web=$(cat "$distro.$working" | grep "class=\"Info\">Home Page" -A2 | grep http | awk -F"href=" '{ print $2 }' | awk -F\" '{ print $2 }' | head -n 1 | tr ',' ' ')


	#echo $id
	echo $name
	echo "Popularity: $rank" # ", User Rating: $reader_rating"
	echo "Based On:$basedon"
	#echo "Origin: $origin"
	echo "Architecture: $arch"
	echo "Desktops: $desktop"
	#gnome_ver
	#plasma_ver
	echo "Package Manager: $packagemanager"
	echo "Release: $releasemodel"
	echo "Init: $init"
	echo "Kernel: $kernel_ver"
	echo "x-server: $xorg_ver"
	if [ -n "${wayland_ver-}" ]; then
		echo "Wayland: $wayland_ver"
	fi
	echo "gcc: $gcc_ver"
	if [ -n "${clang_ver-}" ]; then
		echo "clang: $clang_ver"
	fi
	#echo "Category: $category"
	#echo "Status: $status"
	#echo "Description: $desc"
	#echo "Website: $web"
	echo "Latest version: $lastv, Updated: $lastdate"
	echo ""

	# Add to Database
	echo "$id,$name,$basedon,$origin,$arch,$desktop,$packagemanager,$releasemodel,$init,$kernel_ver,$xorg_ver,$wayland_ver,$gcc_ver,$clang_ver,$category,$status,$rank,$desc,$web,$lastv,$lastdate" >> output.csv

done

#Create and populate sqlite DB 
cmds='
create table active_distros (id INTEGER PRIMARY KEY, Name TEXT NOT NULL); 
.import --csv list.csv active_distros;
.import --csv output.csv db
'
echo "$cmds" | sqlite3 ./output.sqlite3

#cleanup
rm $distro_list
rm *.$working

echo ""
echo "Done. Please see scan_$date/output.sqlite3"
