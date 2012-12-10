#purpose: python wrapper for bamedit tool
#author: Ziru Zhou
#date: October, 2012

import sys, subprocess, tempfile, shutil, glob, os, os.path, gzip
from galaxy import eggs
import pkg_resources
pkg_resources.require( "simplejson" )
import simplejson

CHUNK_SIZE = 1024

def main():
    options = simplejson.load( open( sys.argv[1] ) )
    
    #experiment_name = '_'.join( options['bamout'] ) 
   
    if(options['action'] == "merge"):
	cmdline = "samtools merge  %s %s %s" % ( options['bamout'], options['input1'], options['input2'] )
	if('input3' in options):
		cmdline = "samtools merge  %s %s %s %s" % ( options['bamout'], options['input1'], options['input2'], options['input3'] )
    elif (options['action'] == "split"):
	cmdline = "bash /mnt/galaxyTools/galaxy-central/tools/modENCODE_DCC/bamedit/split.sh %s %s %s" % ( options['bamout'], options['bamout2'], options['input1'] )
    elif (options['action'] == "pileup"):
	cmdline = "perl /mnt/galaxyTools/galaxy-central/tools/modENCODE_DCC/bamedit/pileup.pl %s %s %s %s %s" % ( options['input1'], options['input2'], options['bamout'], options['bamname'], options['refname'] )
    elif (options['action'] == "filter"):
	cmdline = "samtools view -q %s %s -bo %s" % ( options['quality'], options['input1'], options['bamout'] )

    #create tempdir for output files and stderr reports
    tmp_dir = tempfile.mkdtemp() 
    stderr_name = tempfile.NamedTemporaryFile().name
    proc = subprocess.Popen( args=cmdline, shell=True, cwd=tmp_dir, stderr=open( stderr_name, 'wb' ) )
    proc.wait()

    #Do not terminate if error code, allow dataset (e.g. log) creation and cleanup
    if proc.returncode:
        stderr_f = open( stderr_name )
        while True:
            chunk = stderr_f.read( CHUNK_SIZE )
            if not chunk:
                stderr_f.close()
                break
            sys.stderr.write( chunk )
    
if __name__ == "__main__": main()
