#purpose: python wrapper to run peak ranger
#author: Ziru Zhou
#Date: November 2012

import sys, subprocess, tempfile, shutil, glob, os, os.path, gzip
from galaxy import eggs
import pkg_resources
pkg_resources.require( "simplejson" )
import simplejson
import glob
import datetime

CHUNK_SIZE = 1024

def main():
    options = simplejson.load( open( sys.argv[1] ) )
    outputs = simplejson.load( open( sys.argv[2] ) )


    #sets experiment name and sets the chip/input files
    #========================================================================================    
    experiment_name = '_'.join( options['experiment_name'].split() ) #save experiment name

    #cmdline = "bash /mnt/galaxyTools/galaxy-central/tools/modENCODE_DCC/peakranger/peakranger %s -d %s --format bam" % ( options['action'], options['chip_file'] )
    cmdline = "peakranger %s -d %s" % ( options['action'], options['chip_file'] )
    if 'input_file' in options:
        cmdline = "%s -c %s" % ( cmdline, options['input_file'] )

    #set additional options
    #========================================================================================
    if (options['action'] == "nr"):
	output_ranger_file = outputs['output_ranger_file']

	cmdline = "%s --format bam -l %s --verbose > default_output.txt" % ( cmdline, options['extension'] ) 
    elif (options['action'] == "lc"):
	output_ranger_file = outputs['output_ranger_file']

	cmdline = "%s --verbose > default_output.txt" % ( cmdline )
    elif (options['action'] == "wig"):
	output_wigzip_file = outputs['output_wigzip_file']

	cmdline = "%s --format bam -l %s %s %s %s -o ranger_wig" % ( cmdline, options['extension'], options['split'], options['strand'], options['gzip'] ) 
    elif (options['action'] == "wigpe"):
	output_wigzip_file = outputs['output_wigzip_file']

	cmdline = "%s -l %s %s %s %s -o ranger_wig" % ( cmdline, options['extension'], options['split'], options['strand'], options['gzip'] ) 
    elif (options['action'] == "ranger"):
	output_summit_file = outputs['output_summit_file']
	output_region_file = outputs['output_region_file']
	output_details_file = outputs['output_details_file']
	output_report_file = outputs['output_report_file']

	if (options['gene_annotate_file'] != "None"):
		gene_annotate_file = "--gene_annot_file /mnt/galaxyTools/galaxy-central/tools/modENCODE_DCC/peakranger/gene_annotation_files/%s" % options['gene_annotate_file']
		report = "--report"
	elif (options['gene_annotate_file'] == "Upload"):
		gene_annotate_file = options['usr_annot_file']
		report = "--report"
	else:
		gene_annotate_file = ""
		report = ""

	cmdline = "%s -t %s --format bam %s --plot_region %s -l %s -p %s -q %s -r %s -b %s %s %s -o ranger_peak" % ( cmdline, options['threads'], gene_annotate_file, options['plot_region'], options['extension'], options['pvalue'], options['fdr'], options['delta'], options['bandwith'], options['pad'], report )
    elif (options['action'] == "ccat"):
	output_summit_file = outputs['output_summit_file']
	output_region_file = outputs['output_region_file']
	output_details_file = outputs['output_details_file']
	output_report_file = outputs['output_report_file']
	output_ranger_file = outputs['output_ranger_file']
	
	if (options['gene_annotate_file'] != "None"):
		gene_annotate_file = "--gene_annot_file /mnt/galaxyTools/galaxy-central/tools/modENCODE_DCC/peakranger/gene_annotation_files/%s" % options['gene_annotate_file']
		report = "--report"
	elif (options['gene_annotate_file'] == "Upload"):
		gene_annotate_file = options['usr_annot_file']
		report = "--report"
	else:
		gene_annotate_file = ""
		report = ""

	cmdline = "%s --format bam %s --plot_region %s -l %s -q %s --win_size %s --win_step %s --min_count %s --min_score %s %s -o ranger_peak > default_output.txt" % ( cmdline, gene_annotate_file, options['plot_region'], options['extension'], options['fdr'], options['winsize'], options['winstep'], options['mincount'], options['minscore'], report )

    #run cmdline
    #========================================================================================
    tmp_dir = tempfile.mkdtemp()
    stderr_name = tempfile.NamedTemporaryFile().name
    proc = subprocess.Popen( args=cmdline, shell=True, cwd=tmp_dir, stderr=open( stderr_name, 'wb' ) )
    proc.wait()

    #Do not terminate if error code, allow dataset (e.g. log) creation and cleanup
    #========================================================================================
    if proc.returncode:
        stderr_f = open( stderr_name )
        while True:
            chunk = stderr_f.read( CHUNK_SIZE )
            if not chunk:
                stderr_f.close()
                break
            sys.stderr.write( chunk )


    #determine if the outputs are there, copy them to the appropriate dir and filename
    #========================================================================================
    if(options['action'] == "nr" or options['action'] == "lc" or options['action'] == "ccat"):
	created_ranger_file =  os.path.join( tmp_dir, "default_output.txt" )
        if os.path.exists( created_ranger_file ):
        	shutil.move( created_ranger_file, output_ranger_file )

    if(options['action'] == "wig" or options['action'] == "wigpe"):
	if(options['split'] == "-s" or options['strand'] == "-x"):
		if(options['gzip'] == "-z"):
			files = str( glob.glob('%s/*.wig.gz' % tmp_dir) )
			files = files.replace("[", "")
			files = files.replace("]", "")
			files = files.replace(",", "")
			files = files.replace("'", "")
			cmd = "zip -j %s/ranger_wig.zip %s > /dev/null" % (tmp_dir, files)
			#cmd = "tar -czvf %s/ranger_wig.tar %s > /dev/null" % (tmp_dir, files)
			os.system(cmd)
			created_wigzip_file =  os.path.join( tmp_dir, "ranger_wig.zip" )
		else:
			files = str( glob.glob('%s/*.wig' % tmp_dir) )
			files = files.replace("[", "")
			files = files.replace("]", "")
			files = files.replace(",", "")
			files = files.replace("'", "")
			cmd = "zip -j %s/ranger_wig.zip %s > /dev/null" % (tmp_dir, files)
			#cmd = "tar -czvf %s/ranger_wig.tar %s > /dev/null" % (tmp_dir, files)
			os.system(cmd)
			created_wigzip_file =  os.path.join( tmp_dir, "ranger_wig.zip" )
	else:
		if(options['gzip'] == "-z"):
			created_wigzip_file =  os.path.join( tmp_dir, "ranger_wig.wig.gz" )
		else:
			created_wigzip_file =  os.path.join( tmp_dir, "ranger_wig.wig" )
 
	if os.path.exists( created_wigzip_file ):
        	shutil.move( created_wigzip_file, output_wigzip_file )
 
    if(options['action'] == "ranger" or options['action'] == "ccat"):	
	created_summit_file =  os.path.join( tmp_dir, "ranger_peak_summit.bed"  )
	if os.path.exists( created_summit_file ):
        	shutil.move( created_summit_file, output_summit_file )

	created_region_file =  os.path.join( tmp_dir, "ranger_peak_region.bed"  )
	if os.path.exists( created_region_file ):
        	shutil.move( created_region_file, output_region_file )

	created_details_file =  os.path.join( tmp_dir, "ranger_peak_details"  )
	if os.path.exists( created_details_file ):
        	shutil.move( created_details_file, output_details_file )

	#zips the html report and puts it in history, whole report is too big and display in galaxy is very unformatted 
	filename = os.path.splitext(os.path.basename(options['chip_file']))[0]
	filename = filename.upper()
	extension = os.path.splitext(options['chip_file'])[1]
	extension = extension.replace(".", "")
	extension = extension.upper()
	now = datetime.datetime.now()
	date = now.strftime("%Y-%m-%d")
	foldername = "%s_%s_REPORT_%s" % (filename, extension, date)

	created_report_file = os.path.join( tmp_dir, foldername )
	if os.path.exists ( created_report_file ):
		#os.system("cp -rf %s %s" % (created_report_file, "/mnt/galaxyData/files/000/"))
		os.system("cp -rf %s ." % created_report_file)
		os.system("zip -r created_report.zip %s > /dev/null" % foldername)
		#os.system("zip -r created_report.zip /mnt/galaxyData/files/000/%s > /dev/null" % foldername)
		shutil.move( "created_report.zip", output_report_file)


		#os.system("ln -fs %s/index.html %s" %( foldername, output_report_file ))
		#datafoldername = os.path.splitext(os.path.basename(output_report_file))
		#datafolder = os.path.join ("/mnt/galaxyData/files/000/" datafoldername)
		#print "datafolder %s" % datafolder
		#if os.path.exists( datafolder )
		#	os.system("rm -rf %s" % datafolder)
		#	os.system("cp -rf %s/%s/imgs /mnt/galaxyData/files/000/%s" % (tmp_dir, foldername, datafolder))
		#	os.system("cp -rf %s/%s/scripts /mnt/galaxyData/files/000/%s" % (tmp_dir, foldername, datafolder))

    os.unlink( stderr_name )
    shutil.rmtree( tmp_dir )

if __name__ == "__main__": main()
