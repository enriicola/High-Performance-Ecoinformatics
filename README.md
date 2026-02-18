# biomod++

my master of science thesis project!

## todos

- [ ] learn how to copy file from my linux to spartaco and viceversa
- [ ] connect to cineca from my linux

- [ ] check why spartaco does not respond

- [ ] redirect all prints of .def file to null, except errors and warnings

## notes

## remmina - move/copy files between systems

- Right click the RDP connection you are using and select edit
- Under the "Share folder" option enter the path of a folder on the client
- Restart the connection
- The shared folder should be visible in File Explorer in Windows under This PC

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
  step ssh login '<USER_EMAIL>' --provisioner cineca-hpc
fi
'''

### singularity

<!---->
Caro Enrico, dopo aver atteso la solita mezz'ora ci siamo arresi. Per installare terra serve GDAL, ma va installato come rott. Prima di chiedere supporto al CINECA proviamo la strada dei container.

Come dicevo stamattina, per problematiche di sicurezza, nei centri HPC gira Singularity (o la sua versione open Apptainer).

Per cui bisogna, sul portatile o Spartaco

1. crearsi un container Singularity ed installarci sopra tutto quel che serve di R + software di simulazione
2. portarlo su Leonardo e provare

I link di riferimento dovrebber essere questi
<https://docs.hpc.cineca.it/services/singularity.html>

e

<https://cran.r-project.org/web/packages/CausalGPS/vignettes/Singularity-Image.html>

Se hai dubbi chiedi.
<!---->

per sicurezza, nei centri HPC gira Singularity (o la sua versione open Apptainer).
I link di riferimento dovrebber essere questi
<https://docs.hpc.cineca.it/services/singularity.html>
<https://cran.r-project.org/web/packages/CausalGPS/vignettes/Singularity-Image.html>

CONTAINER-NAME=biomod++
sudo apptainer build biomod++.sif biomod++.def
apptainer shell biomod++.sif
apptainer run biomod++.sif

apptainer run --bind $WORK:/work,$CINECA_SCRATCH:/scratch biomod++.sif

### appunti per cineca-leonardo

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
