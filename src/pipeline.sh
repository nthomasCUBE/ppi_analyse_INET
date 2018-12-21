#!/usr/bin/bash

# ------------------------------------------------------------
# ------------------------------------------------------------
#

ZIP_FILE="data/PPIN3_Stats_Kruskal:MannWhit.zip"
STEP=1
MY_LABEL=21dec18
MY_OPT=Emwa1
#
# ------------------------------------------------------------
# ------------------------------------------------------------

# ............................................................

if [ $STEP == 0 ]
then
	FILE_NAME=$(basename ${ZIP_FILE})
	if [ -n "$FILE_NAME" ]; then
		echo "FILENAME::${FILE_NAME}"
		tmp=$(echo $FILE_NAME | sed 's/.zip//g')
		rm -r $tmp
		rm -r __MACOSX
		cp ${ZIP_FILE} .
		echo $FILE_NAME
		unzip ${FILE_NAME}
	fi

fi

# ............................................................

if [ $STEP == 1 ]
then
	if [ $MY_OPT == "noks" ]
	then
		rm -r $MY_OPT
		mkdir $MY_OPT
		for file in PPIN3_Stats_Kruskal:MannWhit/Noks1/Nok*/*xlsx
		do
			echo "${file}"
			echo $MY_OPT
			Rscript src/0_parse_content.R "${file}" $MY_OPT
		done
		python  src/1_restructure_content.py $MY_OPT
		Rscript src/2_make_stat_tests.R $MY_OPT $MY_LABEL
		Rscript src/3_groups_information.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
		Rscript src/3_groups_information_all_lines.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
		exit
	elif [ $MY_OPT == "Emwa1" ]
	then
		rm -r $MY_OPT
		mkdir $MY_OPT
		for file in PPIN3_Stats_Kruskal:MannWhit/Emwa1/Emwa1_*/*xlsx
		do
			echo "${file}"
			Rscript src/0_parse_content.R "${file}" $MY_OPT
		done
		python  src/1_restructure_content.py $MY_OPT
		Rscript src/2_make_stat_tests.R $MY_OPT $MY_LABEL
	        Rscript src/3_groups_information.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
	        Rscript src/3_groups_information_all_lines.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
	fi
fi

# ............................................................

