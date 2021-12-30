#!/bin/sh

if [ -f bib.bib ] && (bibtex2html --version >/dev/null 2>&1); then
    echo "Generating Bibliography"
    bibtex2html -q -noheader -nodoc -nokeywords -noabstract -nobibsource -d -o - \
        bib.bib | head -n -2 > bib.html
    if [ $? = 1 ]; then
        echo "Bibliography generation failed!"
        echo "" > bib.html
    else 
        echo "</table>" >> bib.html
    fi
else
    echo "No Bibliography Found!"
    echo "" > bib.html
fi
 
