#!bin/bash

#purpose: shell script which performs the split option
#author: Ziru Zhou
#date: October, 2012

main()
{
	output1="${1}"
	output2="${2}"
	input="${3}"

	$(samtools view -H ${input} > tmp)
	linecount=$(samtools view ${input} | wc -l)
	half=$(((${linecount} + 1) / 2))
	samtools view ${input} | shuf | split -d -l ${half}

	$(cat tmp x00 > x00h)
	$(cat tmp x01 > x01h)
        samtools view -bSo ${output1} x00h
        samtools view -bSo ${output2} x01h

	rm tmp x00h x01h x00 x01
}
main "${@}"
