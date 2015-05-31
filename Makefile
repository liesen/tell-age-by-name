TOP=1000

.INTERMEDIATE: $(foreach year,$(shell seq 1880 2014),$(addprefix popularnames/,$(addsuffix .html,$(year))))

popularnames/%.html:
	curl -s -d year=$* -d top=$(TOP) -d number=n http://www.socialsecurity.gov/cgi-bin/popularnames.cgi -o $@ --create-dirs

popularnames/%.csv: popularnames/%.html
	python -c "import pandas as pd; pd.read_html('$<', header=0, index_col=0, attrs={'summary': 'Popularity for top $(TOP)'})[0].head($(TOP)).to_csv('$@')"

popularnames: $(foreach year,$(shell seq 1880 2014),$(addprefix popularnames/,$(addsuffix .csv,$(year))))

.INTERMEDIATE: $(foreach decade,$(shell seq 1900 10 2100),$(addsuffix .html,$(addprefix LifeTables/LifeTables_Tbl_7_,$(decade))))

LifeTables/LifeTables_Tbl_7_%.html:
	curl -s 'http://www.ssa.gov/oact/NOTES/as120/LifeTables_Tbl_7_$*.html' -o $@ --create-dirs

LifeTables/LifeTables_Tbl_7_%.csv: LifeTables/LifeTables_Tbl_7_%.html
	python -c "from bs4 import BeautifulSoup; import pandas as pd; pd.read_html(str(BeautifulSoup(open('$<', 'r')).find('table', id=lambda x: x is not None and x.startswith('wp'))), skiprows=3)[0].dropna(how='all').to_csv('$@')"

LifeTables: $(foreach decade,$(shell seq 1900 10 2100),$(addsuffix .csv,$(addprefix LifeTables/LifeTables_Tbl_7_,$(decade))))
