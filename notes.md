# biomod++

my master of science thesis project!

## notes

### bash daniele PER IL CINECA

'''bash
if [ -f ~/.bash_agent ]; then
. ~/.bash_agent
fi

steptest=$(step ssh list --raw '<USER_EMAIL>'| step ssh inspect | grep "Valid")

if [ -z "$steptest" ]
then
  eval $(ssh-agent)
  echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > ~/.bash_agent
  echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> ~/.bash_agent
  step ssh login 'USER_EMAIL' --provisioner cineca-hpc
fi
'''

### singularity

per sicurezza, nei centri HPC gira Singularity (o la sua versione open Apptainer).
I link di riferimento dovrebber essere questi
<https://docs.hpc.cineca.it/services/singularity.html>
<https://cran.r-project.org/web/packages/CausalGPS/vignettes/Singularity-Image.html>

CONTAINER-NAME=biomod++
sudo apptainer build biomod++.sif biomod++.def
apptainer shell biomod++.sif
apptainer run biomod++.sif

apptainer run --bind $WORK:/work,$CINECA_SCRATCH:/scratch biomod++.sif

## appunti per cineca-leonardo

<https://cran.r-project.org/web/packages/CausalGPS/vignettes/Singularity-Image.html>
<https://docs.hpc.cineca.it/services/singularity.html>

noi lavoriamo su E: (toshiba ext) alpine grasslands
ensable modelling_no_parallel.R

raster e terra sono pacchetti per lavorare coi file raster

- son mappe climatiche
- gli altri sono algoritmi che usa

data_1km_eunis.txt è il file
ogni km2 c'è un punto della specie

<www.celsa.svizzera> :)

PCA -> principal component analysis
2 ere:

- presente
- futuro

<https://docs.hpc.cineca.it/general/getting_started.html>
<https://docs.hpc.cineca.it/general/access.html#access-to-the-systems>
<https://docs.hpc.cineca.it/general/users_account.html#manage-your-hpc-credentials>
<>

<https://docs.hpc.cineca.it/general/access.html#how-to-mnage-authtentication-certificates>

<https://www.youtube.com/watch?v=bwY1oNEIALs>
<https://www.youtube.com/watch?v=AwXHIOu6zKY>
<https://www.geeksforgeeks.org/r-language/r-programming-language-introduction/>
<https://www.techtarget.com/searchbusinessanalytics/definition/R-programming-language>
<https://www.coursera.org/articles/what-is-r-programming>
<https://www.geeksforgeeks.org/r-language/r-programming-101/>

<https://www.youtube.com/watch?v=FY8BISK5DpM>
<https://www.youtube.com/watch?v=_V8eKsto3Ug>
<https://www.youtube.com/watch?v=yZ0bV2Afkjc>
