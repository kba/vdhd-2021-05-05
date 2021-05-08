UNZIP = unzip
WGET = wget
GIT_CLONE = git clone --depth 1
JAVA = java

SAXON_HE_VERSION_MAJOR = 9
SAXON_HE_VERSION_MINOR = 9

# Note that the patch version must be < 1-7J
SAXON_HE_VERSION_PATCH = 1-6J

SAXON_HE_ZIP = SaxonHE$(SAXON_HE_VERSION_MAJOR)-$(SAXON_HE_VERSION_MINOR)-$(SAXON_HE_VERSION_PATCH).zip
SAXON_HE_URL = https://netcologne.dl.sourceforge.net/project/saxon/Saxon-HE/$(SAXON_HE_VERSION_MAJOR).$(SAXON_HE_VERSION_MINOR)/$(SAXON_HE_ZIP)
SAXON_HE_JAR = saxon9he.jar

PAGE2TEI_URL = https://github.com/tboenig/page2tei
PAGE2TEI_XSL = page2tei/page2tei-0.xsl

# BEGIN-EVAL makefile-parser --make-help Makefile

help:
	@echo ""
	@echo "  Targets"
	@echo ""
	@echo "    bootstrap    Download Saxon and page2tei"
	@echo "    tei-convert  Convert workspaces to TEI"
	@echo ""
	@echo "  Variables"
	@echo ""
	@echo "    SAXON_HE_VERSION_PATCH  Note that the patch version must be < 1-7J"

# END-EVAL

# Download Saxon and page2tei
bootstrap: $(SAXON_HE_JAR) $(PAGE2TEI_XSL)

$(PAGE2TEI_XSL):
	$(GIT_CLONE) $(PAGE2TEI_URL)

$(SAXON_HE_JAR):
	$(MAKE) $(SAXON_HE_ZIP)
	$(UNZIP) "$(SAXON_HE_ZIP)" "$@"

$(SAXON_HE_ZIP):
	$(WGET) -O "$@" "$(SAXON_HE_URL)"

# Convert workspaces to TEI
tei-convert: demo1-tei.xml demo2-tei.xml

demo1-tei.xml: demo1/mets.xml
	$(JAVA) -jar $(SAXON_HE_JAR) -xsl:$(PAGE2TEI_XSL) -s:$^ -o:$@ PAGEprogram=OCRD PAGEXML=OCR-TESS

demo2-tei.xml: demo2/mets.xml
	$(JAVA) -jar $(SAXON_HE_JAR) -xsl:$(PAGE2TEI_XSL) -s:$^ -o:$@ PAGEprogram=OCRD PAGEXML=OCR-D-OCR
