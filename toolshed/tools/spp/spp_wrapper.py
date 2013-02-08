#purpose: python wrapper to run spp
#author: Ziru Zhou
#Date: November 2012
#####################

import sys, subprocess, tempfile, shutil, glob, os, os.path, gzip
from galaxy import eggs
import pkg_resources
pkg_resources.require( "simplejson" )
import simplejson

CHUNK_SIZE = 1024

def main():
    options = simplejson.load( open( sys.argv[1] ) )
    output_narrow_peak = sys.argv[2]
    output_region_peak = sys.argv[3]
    output_peakshift_file = sys.argv[4]
    output_rdata_file = sys.argv[5]
    output_plot_file = sys.argv[6]
    output_default_file = sys.argv[7]
    script_path = sys.argv[8]

    #set file extensions and set mandatory options
    #======================================================================================    
    experiment_name = '_'.join( options['experiment_name'].split() ) #save experiment name

    chip_file = "%s.bam" % (options['chip_file'])
    subprocess.call(["cp", options['chip_file'], chip_file])

    cmdline = "Rscript %s/run_spp.R -c=%s" % (script_path, chip_file )
    if 'input_file' in options:
        input_file = "%s.bam" % (options['input_file'])
        subprocess.call(["cp", options['input_file'], input_file])
        cmdline = "%s -i=%s" % ( cmdline, input_file )

    #set additional options
    #========================================================================================
    if (options['action'] == "cross_correlation"):
        cmdline = "%s %s %s %s > default_output.txt" % ( cmdline, options['savp'], options['out'], options['rf'] ) 
    elif (options['action'] == "peak_calling"):
        cmdline = "%s -fdr=%s -npeak=%s %s %s %s %s %s > default_output.txt" % ( cmdline, options['fdr'], options['npeak'], options['savr'], options['savd'], options['savn'], options['savp'], options['rf'] ) 
    elif (options['action'] == "idr"):
        cmdline = "%s -npeak=%s %s %s %s %s > default_output.txt" % ( cmdline, options['npeak'], options['savr'], options['savp'], options['out'], options['rf'] ) 
    elif (options['action'] == "custom"):
        cmdline = "%s -s=%s %s -x=%s -fdr=%s -npeak=%s %s %s" % ( cmdline, options['s'], options['speak'], options['x'], options['fdr'], options['npeak'], options['filtchr'], options['rf'] )
        cmdline = "%s %s  %s %s %s %s > default_output.txt" % ( cmdline, options['out'], options['savn'], options['savr'], options['savp'], options['savd'] )

    #run cmdline
    #========================================================================================
    #tmp_dir = tempfile.mkdtemp()
    tmp_dir = os.path.dirname(options['chip_file'])
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
    chip_name = os.path.basename(options['chip_file'])
    input_name = os.path.basename(options['input_file'])

    created_default_file =  os.path.join( tmp_dir, "default_output.txt" )
    if os.path.exists( created_default_file ):
        shutil.move( created_default_file, output_default_file )

    created_narrow_peak =  os.path.join( tmp_dir, "%s_VS_%s.narrowPeak" % (chip_name, input_name) )
    if os.path.exists( created_narrow_peak ):
        shutil.move( created_narrow_peak, output_narrow_peak )
 
    created_region_peak =  os.path.join( tmp_dir, "%s_VS_%s.regionPeak" % (chip_name, input_name) )
    if os.path.exists( created_region_peak ):
        shutil.move( created_region_peak, output_region_peak )

    created_peakshift_file =  os.path.join( tmp_dir, "peakshift.txt" )
    if os.path.exists( created_peakshift_file ):
        shutil.move( created_peakshift_file, output_peakshift_file )

    created_rdata_file =  os.path.join( tmp_dir, "%s.Rdata" % chip_name )
    if os.path.exists( created_rdata_file ):
        shutil.move( created_rdata_file, output_rdata_file )

    created_plot_file =  os.path.join( tmp_dir, "%s.pdf" % chip_name )
    if os.path.exists( created_plot_file ):
        shutil.move( created_plot_file, output_plot_file )

    
    os.unlink( stderr_name )
    #os.rmdir( tmp_dir )

if __name__ == "__main__": main()