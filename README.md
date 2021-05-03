# Demos OCR@vDHD Session 1


## Demo 1

> Start with a bunch of images, create workspace, run tesseract

### Browse to https://archive.org/details/2917685.0001.001.umich.edu/page/2/mode/2up

### Copy link for "SINGLE PAGE PROCESSED TIFF ZIP"

### Download

```sh
wget 'https://archive.org/download/2917685.0001.001.umich.edu/2917685.0001.001.umich.edu_tif.zip'
```

### Unzip

```sh
unzip 2917685.0001.001.umich.edu_umichbook.zip
```

### Rename folder for clarity

```sh
mv 2917685.0001.001.umich.edu_tif IMG
```

### Create an empty workspace

```sh
ocrd workspace init
```

### Assign it an identifier

```sh
ocrd workspace set-id kropotkin-paris
```

### Add all the files with `ocrd workspace bulk-add` or a for loop

```sh
ocrd workspace bulk-add \
  --regex '^.*/(?P<fileGrp>[^/]+)/(?P<prefix>.*)(?P<pageId>\d{4})\.(?P<ext>[^\.]*)$' \
  --page-id 'PHYS_{{ pageId }}' \
  --file-id '{{ fileGrp }}_{{ pageId }}' \
  --url '{{ fileGrp }}/{{ prefix }}{{ pageId }}.{{ ext }}' \
  -G IMG \
  IMG/*.tif
```

If that is too daunting to adapt for your own data, an easier-to-read but slower method with bash for-loops:

```sh
for file in IMG/*.tif;do
  pageid=$(echo "$file" | grep -Po '\d\d\d\d.tif' |grep -Po '\d+')
  fileGrp="$(dirname $file)"
  ocrd workspace add --file-id "${fileGrp}_$pageid" --page-id "PHYS_$pageid" --file-grp $fileGrp $file
done
```

### Minimalist workflow

```sh
ocrd process "tesserocr-recognize -P segmentation_level region -P textequiv_level word -P find_tables true -P model deu -I IMG -O OCR-TESS"
```

The results are in the `OCR-D-OCR` file group / folder.

## Demo 2

> Start with a METS from SBB, run a more complex workflow on it

### Browse to https://digital.staatsbibliothek-berlin.de/werkansicht?PPN=PPN680203753

### Select the METS XML from the "Vollständige Bibliografische Informationen"

-> https://content.staatsbibliothek-berlin.de/dc/PPN680203753.mets.xml

### Clone the workspace

```sh
ocrd workspace clone https://content.staatsbibliothek-berlin.de/dc/PPN680203753.mets.xml
```

### Inspect available file groups

```sh
ocrd workspace find -k fileGrp -k url -k mimetype
```

### Download all images in DEFAULT file group

```sh
ocrd workspace find --file-grp DEFAULT --download
```

### Run the second workflow example from the Workflow Guide

Since our file group is called `DEFAULT`, `OCR-D-IMG` is replaced with `DEFAULT` here.

```sh
ocrd process \
  "cis-ocropy-binarize -I DEFAULT -O OCR-D-BIN" \
  "anybaseocr-crop -I OCR-D-BIN -O OCR-D-CROP" \
  "skimage-binarize -I OCR-D-CROP -O OCR-D-BIN2 -P method li" \
  "skimage-denoise -I OCR-D-BIN2 -O OCR-D-BIN-DENOISE -P level-of-operation page" \
  "tesserocr-deskew -I OCR-D-BIN-DENOISE -O OCR-D-BIN-DENOISE-DESKEW -P operation_level page" \
  "cis-ocropy-segment -I OCR-D-BIN-DENOISE-DESKEW -O OCR-D-SEG -P level-of-operation page" \
  "cis-ocropy-dewarp -I OCR-D-SEG -O OCR-D-SEG-LINE-RESEG-DEWARP" \
  "calamari-recognize -I OCR-D-SEG-LINE-RESEG-DEWARP -O OCR-D-OCR -P checkpoint_dir qurator-gt4histocr-1.0"
```

The results are in the `OCR-D-OCR` file group / folder.
