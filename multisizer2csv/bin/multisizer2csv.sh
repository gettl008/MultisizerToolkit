#!/usr/bin/env bash
set -e
###############################################
function beginswith { 
	case $2 in 
		"$1"*) true;; 
		*) false;; 
	esac
}
###############################################
usage="\nSYNOPSIS:\n\nmultisizer2csv.sh -s <SAMPLE_INFO> [OPTIONS]\n\n\
	Converts multisizer output data (.#m4 files) to CSV format.\n\
	Output consists of files containing diameter binned raw count data (counts), counts per ml (cpm), fraction of total counts represented by each diameter bin (freqs), and fraction of total volume represented by each diameter bin (volumetricfraction). These data are outputted as individual files for each sample and as combined files.\n\n\
OPTIONS:\n\
  -d | --dir\t\t[DIR]		\tQuoted string of directories containing relevant\n\
			                \t\t\t\tfiles (default = './').\n\
  -s | --sample_info\t[FILE]\tCSV of sample info with the following columns\n\
							\t\t\t\t(REQUIRED):\n\
			  				\t\t\t\tcol1=fileBasename\n\
							\t\t\t\tcol2=sampleName\n\
							\t\t\t\tcol3=diluentAmt_ul\n\
							\t\t\t\tcol4=sampleAmt_ul\n\
							\t\t\t\tcol5=measuredAmt_ul\n\
							\t\t\t\tNOTE: File should not contain header information\n\
							\t\t\t\tExample Format:\n\
							\t\t\t\t__147\tblank\t10000\t100\t100\n\
							\t\t\t\t__148\tsample1\t10000\t100\t100\n\
							\t\t\t\t__149\tsample2\t10000\t20\t100\n\
  -o | --output_dir\t[DIR]\tOutput directory (default = './output)\n\
  -b | --blank\t\t[STR]\tName used to designate blank run in sample_info\n\
					   \t\t\t\tfile if you wish to subtract those counts from\n\
					   \t\t\t\tthe rest.\n\
  -h | --help\t\t\tPrint help message\n\n\
AUTHOR:\n\
Noah Gettle 2017"

dir=`pwd`
output_dir=$dir/output
while [ "$1" != "" ]
do
	case $1 in
		-d | --dir)
			if ! `beginswith "-" "$2"`
			then
				shift
				if ! test -d $1
				then
					echo "Input directory $1 does not exist"
					exit 1
				else
					dir=$1
				fi
			fi;;
		-s | --sample_info)
			if ! `beginswith "-" "$2"`
			then
				shift
				if ! test -f $1
				then
					echo "Sample info file $1 does not exit"
					exit 1
				else
					sample_info=$1
				fi
			fi;;
		-o | --output_dir)
			if ! `beginswith "-" "$2"`
			then
				shift
				output_dir=$1
			fi;;
		-b | --blank)
			if ! `beginswith "-" "$2"`
			then
				shift
				blank=$1
			fi;;
		-h | --help)
			echo -e $usage
			exit 1;;
		*)
			echo -e "\nERROR: $1 is not a valid option.\n$usage"
			exit 1;;
	esac
	shift
done

if [ "$sample_info" == "" ]
then
	echo -e "Sample info file required\n$usage"
	exit 1
fi
if [ "$dir" == "" ]
then
	echo -e "Input directory required\n$usage"
	exit 1
fi

# Convert sample info CSV into readable format
tr '\015' '\n' < $sample_info > $dir/tmp.info.csv

rm -rf $output_dir/*.csv
mkdir -p $output_dir
header_line="volume_um3,diameter_um,raw.counts,counts.per.ml,volumetric.fraction"
for sampleline in `cat $dir/tmp.info.csv`
do
	if ! `echo $line | grep -q $'^#'`
	then
		filename=`echo $sampleline | awk -F',' '{print $1}'`
		outfilename=`echo $sampleline | awk -F"," '{print $2}'`
		outfile=$output_dir/$outfilename.csv
		# Use sample info to get relevant dilution factor
		dilution1=`echo $sampleline | awk -F"," '{print $3}'`
		dilution2=`echo $sampleline | awk -F"," '{print $4}'`
		dilution3=`echo $sampleline | awk -F"," '{print $5}'`
		dilution_factor=`echo "($dilution2/($dilution1 + $dilution2))*($dilution3/1000)" | bc -l`
		# Start file with header line if not sample file not already present
		if ! test -f $outfile
		then
			# echo "$outfilename"
			echo -e $header_line > $outfile
		fi
		# echo -e "\t$filename"
		# Extract pulse data from #m4 file and convert to csv
		start_line=`grep -n '\[\#Bindiam\]' $dir/$filename.#m4 | awk -F':' '{print $1}'`
		start_line=`expr $start_line + 1`
		end_line=`tail -n +$start_line $dir/$filename.#m4 | grep -n $'^\[' | head -1 | awk -F':' '{print $1}'`
		end_line=`expr $end_line - 1`
		tail -n +$start_line $dir/$filename.#m4 | head -$end_line > $output_dir/bin.txt
		start_line=`grep -n '\[\#Binheight\]' $dir/$filename.#m4 | awk -F':' '{print $1}'`
		start_line=`expr $start_line + 1`
		end_line=`tail -n +$start_line $dir/$filename.#m4 | grep -n $'^\[' | head -1 | awk -F':' '{print $1}'`
		end_line=`expr $end_line - 1`
		tail -n +$start_line $dir/$filename.#m4 | head -$end_line > $output_dir/height.txt
		paste -d , $output_dir/bin.txt $output_dir/height.txt | tr -d '\015' > $output_dir/tmp.csv
		# Covert pulse data to counts per ml
		processMultisizerData.R $output_dir/tmp.csv $output_dir/tmp2.csv $dilution_factor
		cat $output_dir/tmp2.csv >> $outfile
		rm -rf $output_dir/tmp*
		rm -rf $output_dir/bin.txt $output_dir/height.txt
	fi
done
rm -rf $dir/tmp.info.csv

echo "Combining data"
combineMultisizerCSVs.R $output_dir $output_dir/combined $blank


