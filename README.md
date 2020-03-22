# 2019 Novel Coronavirus COVID-19 (2019-nCoV) Web Crawler Data Repository by Johns Hopkins CSSE

## Special fork by Joel Kalvesmaki: tabular analyses

Tables of perhaps greatest interest, showing absolute numbers, and numbers per million population:
* [Grouped by country](Country-Region.html)
* [Grouped by language](language.html) (Note: this counts an entire country that has that language, even if minority, based on 
[json data for languages in countries](https://github.com/samayo/country-json/blob/master/src/country-by-languages.json))
* [Grouped by government type](government.html)
* [Grouped by religion](religion.html)
* [Grouped by landlocked or not](landlocked.html)

I have hastily written an XSLT stylesheet that combines the data from 
[Hopkins](https://github.com/CSSEGISandData/COVID-19) with the data provided by 
[@samoyo](https://github.com/samayo/country-json) to present analyses of the table of confirmed cases, deaths, and recoveries grouped by different national traits. The table javascript comes from [the version of TableSorter provided by @mottie](https://mottie.github.io/tablesorter/docs/).

I plan on refreshing the data only periodically, when I'm personally curious. You can fork or pull the project yourself and pull the files yourself, either from the master branch or the web-data one. You'll get the latest data working off the web-data branch, and being sure to pull from Hopkins's repo.

## Original notice

This is the web crawler data repository for the 2019 Novel Coronavirus Visual Dashboard operated by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). Also, Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL).

<br><br>
<b>Current Data Crawling Sources:</b><br>

* BNO News: https://bnonews.com/index.php/2020/02/the-latest-coronavirus-cases/  <br>
* Worldometer: https://www.worldometers.info/coronavirus/ <br>

<b>Contact Us: </b><br>
* Email: jhusystems@gmail.com
<br><br>

<b>Terms of Use:</b><br>

This GitHub repo and its contents herein, including all data, mapping, and analysis, copyright 2020 Johns Hopkins University, all rights reserved, is provided to the public strictly for educational and academic research purposes.  The Website relies upon publicly available data from multiple sources, that do not always agree. The Johns Hopkins University hereby disclaims any and all representations and warranties with respect to the Website, including accuracy, fitness for use, and merchantability.  Reliance on the Website for medical guidance or use of the Website in commerce is strictly prohibited.
