import subprocess
import os
import sys

#os.chdir('/home/zyz293/dynamfit/dynamfit_v3/compile')
run = "./a.out %s %s %s %s %s" %(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
# subprocess.call(run)
os.system(run)
# there are five arguments following ./a.out command
# argv[1] is the name of the upload file, should be upcase
# argv[2] is weight: 0.0, 1.0 or 2.0
# argv[3] is standard deviation, 1 for value, 2 for unity
# argv[4] is # of element to use: should > 2 & <= 104
# argv[5] is 1 for compliance, 2 for modulus
