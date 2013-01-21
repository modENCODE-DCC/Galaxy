#!/bin/bash

# idrPlotWrapper.sh
# OICR: Kar Ming Chu
# July 2012

# BASH wrapper for batch-consistency-plot.r (part of the IDR package)
# For use with Galaxy 

# Usage of batch-consistency-plot.r: Rscript batch-consistency-plot-merged.r [npairs] [output.dir] [input.file.prefix 1, 2, 3 ...]
#	npairs - will be a constant, since Galaxy requires explicit control over input and output files

# Usage of THIS SCRIPT: ./idrPlotWrapper.sh em uri outputfile
#	em - em.sav file provided by Galaxy
#	uri - uri.sav file provided by Galaxy
#	outputfile - output file name specified by Galaxy

main() {
	EM="${1}" 		# absolute file path to em.sav file, provided by Galaxy
	URI="${2}"		# absolute file parth to uri.sav file, provided by Galaxy
	OUTFILE="${3}"		# name of desired output file
	script_path="${4}"

	cp "${EM}" ./idrPlot-em.sav	# cp to this directory and rename so they can be found by idrPlot
	cp "${URI}" ./idrPlot-uri.sav
	
	Rscript "$script_path/batch-consistency-plot.r" "$script_path" 1 ./idrPlot idrPlot

	# convert post script to pdf file
 	ps2pdf ./idrPlot-plot.ps ./idrPlot-plot.pdf

	# rename to output file name
	mv ./idrPlot-plot.pdf "${OUTFILE}"

	# clean up
	rm idrPlot-em.sav
	rm idrPlot-uri.sav
}

main "${@}"
