# Distrowatch scraper
Download whole distrowatch database with information on each distribution to .csv and .sqlite

This is a fork of [https://github.com/sxiii/distrowatch-scraper/]

Some of the data fields were broken and I wanted to take the scraper in a different direction.
Porting the data to sqlite makes it much easier to parse the data and find an exact distridution that suits my needs.

This script pulls the html file of all active distros on DistroWatch and parses them.

** I am not a programmer, but I have done my best to write decent code. There may be bugs. **

---

## Requirements
Tested using Debian.
* html2text
* wget
* awk
* sed
* grep
* sqlite3

## How to use the script
1. Install the requirements
   ```sudo apt install -y html2text wget awk sed grep sqlite3```
2. Clone this repository or download dw_scraper.sh
3. Make the script executable ```chmod +x dw_scraper.sh```
4. Run it ```./parse.sh``` (May take several minutes)
5. A folder with todays date will be created, with the databases

## Example sqlite Query

As an example, lets say you wanted a desktop ditribution that supports Gnome and SystemD with the most up to date kernel, but would also like to know if Wayland is supported.

```
SELECT 
	CAST(rank as INT) as 'Rank',
	name as 'Name', 
	lastv as 'Version',
	kernel_ver as 'Kernel Ver.',
	releasemodel as 'Release Type',
	wayland_ver as 'Wayland Ver',
	lastdate as 'Updated'
FROM db
WHERE init like '%systemd%'
AND desktop like '%GNOME%'
AND category like '%Desktop%'
ORDER by kernel_ver DESC;
```

## Results scheme
* id - Distrowatch id (eg: distrowatch.com/table.php?distribution=__debian__)
* name - Distro Name
* basedon - Distribution that it is based on
* origin - Country of Origin
* arch - CPU Architecture
* desktop - Supported Desktop Environments
* packagemanager - Supported Package Managers
* releasemodel - Release Model (Rolling, Fixed, etc)
* init - Init System (systemd, runit, etc)
* kernel_ver - Current linux Kernel
* xorg_ver - X Server Version (if used)
* wayland_ver - Wayland Version (if used)
* gcc_ver - GCC Version
* clang_ver - Clang Version (if used)
* category - Distro Category (Desktop, Server, etc)
* status - Distribution Status (Active, Dorman, etc)
* rank - Popularity Ranking (1 is most popular)
* desc - Distribution Description
* web - Ditribution Website
* lastv - Latest Version
* lastdate - Date of last update

## Limitations
* This script cannot differentiate between different versions of a distro (eg: Debian stable vs testing, openSUSE leap vs tumbleweed). The first entry on each page will be chosen. I recommend checking the `lastv` field to know what has been selected.
* The data from this tool is only as up to date as DistroWatch is.

## Major changes from xsiii version
* Only currently active distributions are scraped
* Added a lot more parameters
* Removed Plotting Functionality
* Added database funtionality

## Possible Updates
* Add Gnome/KDE supported version numbers (Say if you were looking for KDE 6)
