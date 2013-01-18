#!/bin/bash
# Converts macs xls output to narrowPeak output

# Command Usage: macs2npk.sh INPUTFILE OUTPUTFILE

if [[ "$#" -lt 1 ]]
    then
    echo $(basename $0) 1>&2
    echo "Converts MACS peak caller xls output file to narrowPeak format" 1>&2
    echo "USAGE:" 1>&2
    echo "$(basename $0) <MACSXlsFile> <outputDir>" 1>&2
    exit 1 
fi

MACSFILE=$1
if [[ ! -e ${MACSFILE} ]]
    then
    echo "MACS xls file ${MACSFILE} does not exist" 1>&2
    exit 1
fi
# ODIR=$(dirname ${MACSFILE})
# [[ $# -gt 1 ]] && ODIR=$2
# if [[ ! -d ${ODIR} ]]
#    then
#    echo "Output directory ${ODIR} does not exist" 1>&2
#    exit 1
# fi

# OFILE="${ODIR}/$(echo $(basename ${MACSFILE} '_peaks.xls')).regionPeak.gz"
OFILE="${2}"

# XLS format
# chr start stop length summit tags -10log10(pvalue) fold_enrichment %FDR

# narrowPeak format
# chr start stop name score strand signalValue -log10(pValue) -log10(qValue) summit

# Remove comments #
# Remove empty lines
# Remove header
# Sort by p-value and then rearrange columns
# adjust start coordinates

# Check if header has FDR column
header=$(sed -r -e '/^#/d' -e '/^$/d' "${MACSFILE}" | head -1)
hasFdr=0
echo ${header} | grep -q 'FDR' && hasFDR=1

if [[ ${hasFDR} -eq 1 ]]
    then
    sed -r -e '/^#/d' -e '/^$/d' "${MACSFILE}" | \
	sed 1d | \
	sort -k7nr,7nr | \
	awk '$2 < 1 {$2=1} {printf "%s\t%d\t%d\t%d\t%s\t.\t%s\t%s\t%f\t%d\n",$1,$2-1,$3,NR,$6,$8,$7/10,-log(($9+1e-30)/100)/log(10),$5}' > ${OFILE}
else
    sed -r -e '/^#/d' -e '/^$/d' "${MACSFILE}" | \
	sed 1d | \
	sort -k7nr,7nr | \
	awk '$2 < 1 {$2=1} {printf "%s\t%d\t%d\t%d\t%s\t.\t%s\t%s\t-1\t%d\n",$1,$2-1,$3,NR,$6,$8,$7/10,$5}' > ${OFILE}
fi
