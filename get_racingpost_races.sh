#!/bin/sh
#
# extract racing information from racingpost.co.uk website and store them in
# subdirectories according to date and race
#
# audit trail
# 28-JAN-2002  rg  first version
#                  support for subdirs and newer version of wget
#                  copying different nags and moving cards one dir up
# 29-JAN-2002  rg  small HTML markup fix
#
# ---------------------
# configuration section
# ---------------------
#
# target directory to store data in
BASE_PATH="/home/tmp/www/pages/pferde/vollblut/racingpost"
#
# get parts of current date
CURRENT_YEAR=`date +%Y`
CURRENT_MONTH=`date +%m`
CURRENT_DAY=`date +%d`
#
# provide three letter acronym for current month
case ${CURRENT_MONTH} in
	01)	CURRENT_MONTH_NAME="Jan" ;;
	02)	CURRENT_MONTH_NAME="Feb" ;;
	03)	CURRENT_MONTH_NAME="Mar" ;;
	04)	CURRENT_MONTH_NAME="Apr" ;;
	05)	CURRENT_MONTH_NAME="May" ;;
	06)	CURRENT_MONTH_NAME="Jun" ;;
	07)	CURRENT_MONTH_NAME="Jul" ;;
	08)	CURRENT_MONTH_NAME="Aug" ;;
	09)	CURRENT_MONTH_NAME="Sep" ;;
	10)	CURRENT_MONTH_NAME="Oct" ;;
	11)	CURRENT_MONTH_NAME="Nov" ;;
	12)	CURRENT_MONTH_NAME="Dec" ;;
esac
#
# create directory to store data in
mkdir ${BASE_PATH}/${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY}
#
# temporary files to hold data for parsing
# so we have to make as few trips to the original website as possible
OVERVIEW_FILE="${BASE_PATH}/${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY}/index.txt"
RACELIST_FILE="${BASE_PATH}/${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY}/racelist.txt"
#
# URL that contains race overview
OVERVIEW_URL="www.racingpost.co.uk/horses/?MIval=v2_meetings_monitor&day=${CURRENT_DAY}&month=${CURRENT_MONTH_NAME}&year=${CURRENT_YEAR}"
#
# retrieve race overview and store locally
lynx -source ${OVERVIEW_URL} > ${OVERVIEW_FILE}
#
# extract all races
cat ${OVERVIEW_FILE} | grep "<a href=javascript:OpenWindowNew" | grep "v2_card_meeting3" > ${RACELIST_FILE}
#
# for each race retrieve detail data
cat ${RACELIST_FILE} | awk -F"'" {'print $2'} | while read RACE_URL; \
	do \
	CARDS=`echo ${RACE_URL}`;
	COLOUR_CARDS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_card_meeting/g'`;
	SPOTLIGHTS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_meeting_spotlights/g'`;
	SELECTIONS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_selection_box_meeting/g'`;
	POSTMARK_RATINGS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_postmark_meeting/g'`;
	TOPSPEED_RATINGS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_topspeed_meeting/g'`;
	OFFICIAL_RATINGS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_official_meeting/g'`;
	POSTDATA_ANALYSIS=`echo ${RACE_URL} | sed -e 's/v2_card_meeting3/v2_postdata_meeting/g'`;
	COUNTRY=`echo ${RACE_URL} | awk -F"&cntry=" {'print $2'}`;
	COURSE=`echo ${RACE_URL} | awk -F"&crs=" {'print $2'} | awk -F"&" {'print $1'}`;
	FILE_PATH=${BASE_PATH}/${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY}/${COURSE}-${COUNTRY};
	mkdir ${FILE_PATH};
	cd ${FILE_PATH};
	#
	# generate index.html
	echo "<HTML>" > index.html
	echo "<HEAD>" >> index.html
	echo "	<TITLE>Racingpost - Archiv</TITLE>" >> index.html
	echo "</HEAD>" >> index.html
	echo "<BODY BACKGROUND=\"#FFFFFF\">" >> index.html
	echo " " >> index.html
	echo "<FONT FACE=\"Arial, Helvetica, Verdana\" COLOR=\"#000000\" SIZE=\"2\">" >> index.html
	echo "<B>${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY} - ${COURSE} ${COUNTRY}</B><BR>" >> index.html
	echo "<BR>" >> index.html
	echo "--------------------------------------------------------------"
	echo ${CURRENT_YEAR}-${CURRENT_MONTH}-${CURRENT_DAY} "|" ${COURSE} ${COUNTRY}
	echo "--------------------------------------------------------------"
	#
	# get cards
	echo "Getting cards..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${CARDS};
	SAVED_FILE=index.html\?`echo ${CARDS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} cards.html
	#
	# update index.html
	echo "<A HREF=\"cards.html\" TARGET=\"_self\">Cards</A><BR>" >> index.html
	#
	# get colour cards
	echo "Getting color cards..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories ${COLOUR_CARDS};
	SAVED_FILE=./rpost/index.html\?`echo ${COLOUR_CARDS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} colour_cards.tmp
	cat colour_cards.tmp | sed -e 's/\.\.\/nags/nags/g' > colour_cards.html
	rm colour_cards.tmp
	#
	# update index.html
	echo "<A HREF=\"colour_cards.html\" TARGET=\"_self\">Colour Cards</A><BR>" >> index.html
	#
	# get spotlights
	echo "Getting spotlights..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories ${SPOTLIGHTS};
	SAVED_FILE=./rpost/index.html\?`echo ${SPOTLIGHTS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} spotlights.tmp
	cat spotlights.tmp | sed -e 's/\.\.\/nags/nags/g' > spotlights.html
	rm spotlights.tmp
	#
	# update index.html
	echo "<A HREF=\"spotlights.html\" TARGET=\"_self\">Spotlights</A><BR>" >> index.html
	#
	# delete rpost directory
	rm -rf rpost
	#
	# get selections
	echo "Getting selections..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${SELECTIONS};
	SAVED_FILE=index.html\?`echo ${SELECTIONS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} selections.html
	#
	# update index.html
	echo "<A HREF=\"selections.html\" TARGET=\"_self\">Selections</A><BR>" >> index.html
	#
	# get postmark ratings
	echo "Getting postmark ratings..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${POSTMARK_RATINGS};
	SAVED_FILE=index.html\?`echo ${POSTMARK_RATINGS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} postmark_ratings.html
	#
	# update index.html
	echo "<A HREF=\"postmark_ratings.html\" TARGET=\"_self\">Postmark Ratings</A><BR>" >> index.html
	#
	# get topspeed ratings
	echo "Getting topspeed ratings..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${TOPSPEED_RATINGS};
	SAVED_FILE=index.html\?`echo ${TOPSPEED_RATINGS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} topspeed_ratings.html
	#
	# update index.html
	echo "<A HREF=\"topspeed_ratings.html\" TARGET=\"_self\">Topspeed Ratings</A><BR>" >> index.html
	#
	# get official ratings
	echo "Getting official ratings..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${OFFICIAL_RATINGS};
	SAVED_FILE=index.html\?`echo ${OFFICIAL_RATINGS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} official_ratings.html
	#
	# update index.html
	echo "<A HREF=\"official_ratings.html\" TARGET=\"_self\">Official Ratings</A><BR>" >> index.html
	#
	# get postdata analysis
	echo "Getting postdata analysis..."
	wget --quiet --no-clobber --page-requisites --convert-links --no-host-directories --no-directories ${POSTDATA_ANALYSIS};
	SAVED_FILE=index.html\?`echo ${POSTDATA_ANALYSIS} | awk -F"?" {'print $2'}`;
	mv ${SAVED_FILE} postdata_analysis.html
	#
	# update index.html
	echo "<A HREF=\"postdata_analysis.html\" TARGET=\"_self\">Postdata Analysis</A><BR>" >> index.html
	#
	# getting forms
	echo "Getting forms..."
	cat ${OVERVIEW_FILE} | grep "v2_selection_box" | grep "race_id" | grep "${COURSE}" | awk -F"&race_id=" {'print $2'} | awk -F"&" {'print $1'} | while read RACE_ID; \
		do \
		echo ${RACE_ID};
		FORM_URL=`cat ${OVERVIEW_FILE} | grep "v2_card_and_horse_form" | grep "${RACE_ID}" | awk -F"'" {'print $2'}`;
		lynx -source "${FORM_URL}" > ${FILE_PATH}/form_${RACE_ID}.html;
		echo "<A HREF=\"form_${RACE_ID}.html\" TARGET=\"_self\">Form Rennen No. ${RACE_ID}</A><BR>" >> index.html
		done;
	echo " "
	echo " "
	#
	# update index.hmtl
	echo "</FONT>" >> ${FILE_PATH}/index.html
	echo "</BODY>" >> ${FILE_PATH}/index.html
	echo "</HTML>" >> ${FILE_PATH}/index.html
	#
	# --- end ---
	done;
#
# delete temp files
rm -f ${OVERVIEW_FILE} > /dev/null
rm -f ${RACELIST_FILE} > /dev/null

