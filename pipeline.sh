#!/usr/bin/bash

# ------------------------------------------------------------
ZIP_FILE="data/PPIN3_Stats_Kruskal:MannWhit_V2_14jan19.zip"
STEP=ALL
MY_LABEL=`date +%Y-%m-%d`
MY_OPT=$1
# ------------------------------------------------------------

if [ $MY_OPT == "Emwa1" ] || [ $MY_OPT == "noks" ]
then
	echo "Processing ${MY_OPT}"
else
	echo "ERROR:only Emwa1 and noks allowed"
	exit
fi

# ............................................................

mkdir $MY_LABEL
cd $MY_LABEL

if [ $STEP == 0 ] || [ $STEP == "ALL" ]
then
	echo "STEP::0"
	FILE_NAME=$(basename ${ZIP_FILE})
	if [ -n "$FILE_NAME" ]; then
		echo "FILENAME::${FILE_NAME}"
		rm -r __MACOSX
		rm -r PPIN3_Stats_Kruskal:MannWhit
		cp ../${ZIP_FILE} .
		echo $FILE_NAME
		unzip ${FILE_NAME}
		rm -r __MACOSX
	fi
fi

# ............................................................

if [ $STEP == 1 ] || [ $STEP == "ALL" ]
then
	if [ $MY_OPT == "noks" ]
	then
		rm -r $MY_OPT
		mkdir $MY_OPT
		for file in PPIN3_Stats_Kruskal:MannWhit/Noks1/Nok*/*xlsx
		do
			echo "${file}"
			echo $MY_OPT
			Rscript ../src/0_parse_content.R "${file}" $MY_OPT
		done
		python  ../src/1_restructure_content.py $MY_OPT
		Rscript ../src/2_make_stat_tests.R $MY_OPT $MY_LABEL
		Rscript ../src/3_groups_information.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
		Rscript ../src/3_groups_information_all_lines.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
	elif [ $MY_OPT == "Emwa1" ]
	then
		rm -r $MY_OPT
		mkdir $MY_OPT
		for file in PPIN3_Stats_Kruskal:MannWhit/Emwa1/Emwa1_*/*xlsx
		do
			echo "${file}"
			Rscript ../src/0_parse_content.R "${file}" $MY_OPT
		done
		python  ../src/1_restructure_content.py $MY_OPT
		Rscript ../src/2_make_stat_tests.R $MY_OPT $MY_LABEL
	        Rscript ../src/3_groups_information.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
	        Rscript ../src/3_groups_information_all_lines.R ${MY_OPT}/2_make_stat_tests_${MY_LABEL}.xlsx
	fi
fi
# ............................................................

# ............................................................

if [ $STEP == 2 ] || [ $STEP == "ALL" ]
then
	Rscript ../5_make_kruskal_wallis_test.R $MY_OPT
	python ../6_merge_results.py $MY_OPT
	Rscript ../7_overview_eds_edr.R $MY_OPT
fi
