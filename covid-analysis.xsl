<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all"
   xmlns:tan="tag:textalign.net,2015:ns" xmlns:h="http://www.w3.org/1999/xhtml" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
   
   <xsl:output indent="yes"/>
   <xsl:template match="document-node()" mode="#all" priority="-1">
      <xsl:document>
         <xsl:apply-templates mode="#current"/>
      </xsl:document>
   </xsl:template>
   <xsl:template match="*" mode="#all" priority="-1">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="processing-instruction() | comment() | namespace-node()" mode="#all" priority="-1"/>
   
   
   <xsl:variable name="elements-to-group-by" as="xs:string+">
      <xsl:text>Country-Region</xsl:text>
      <xsl:text>language</xsl:text>
      <xsl:text>government</xsl:text>
      <xsl:text>height</xsl:text>
      <xsl:text>elevation</xsl:text>
      <xsl:text>area</xsl:text>
      <xsl:text>temperature</xsl:text>
      <xsl:text>religion</xsl:text>
      <xsl:text>expectancy</xsl:text>
      <xsl:text>landlocked</xsl:text>
   </xsl:variable>
   
   <xsl:param name="element-choice" as="xs:integer" select="1"/>
   
   <xsl:param name="group-by-what-element" as="xs:string"
      select="$elements-to-group-by[$element-choice]"/>
   
   <xsl:variable name="covid-daily-reports-uris"
      select="uri-collection('csse_covid_19_data/csse_covid_19_daily_reports')"/>
   
   <xsl:variable name="country-populations"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-population.json')))"/>
   
   <!-- items to group by -->
   <xsl:variable name="country-languages"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-languages.json')))"/>
   <xsl:variable name="country-government-type"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-government-type.json')))"/>
   <xsl:variable name="country-avg-male-height"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-avg-male-height.json')))"/>
   <xsl:variable name="country-elevation"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-elevation.json')))"/>
   <xsl:variable name="country-surface-area"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-surface-area.json')))"/>
   <xsl:variable name="country-yearly-average-temperature"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-yearly-average-temperature.json')))"/>
   <xsl:variable name="country-religion"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-religion.json')))"/>
   <xsl:variable name="country-life-expectancy"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-life-expectancy.json')))"/>
   <xsl:variable name="country-landlocked"
      select="tan:jsonxmlmap-to-xml(json-to-xml(unparsed-text('../country-json/src/country-by-landlocked.json')))"/>
   
   
   <xsl:variable name="latest-covid-stats-uri" as="xs:string?">
      <xsl:for-each select="$covid-daily-reports-uris[ends-with(., 'csv')]">
         <xsl:sort order="descending"/>
         <xsl:if test="position() = 1">
            <xsl:value-of select="."/>
         </xsl:if>
      </xsl:for-each>
   </xsl:variable>
   
   <xsl:variable name="latest-stat" select="unparsed-text-lines($latest-covid-stats-uri)"/>
   
   <xsl:function name="tan:csv-to-xml" as="element()">
      <!-- Input: a string with header lines; a sequence of strings, one entry per string -->
      <!-- Output: the data as xml -->
      <xsl:param name="header-row" as="xs:string?"/>
      <xsl:param name="data-rows" as="xs:string*"/>
      <xsl:variable name="these-heads" select="tokenize($header-row, ',')"/>
      <csv>
         <xsl:for-each select="$data-rows">
            <item>
               <xsl:for-each select="tan:tokenize-csv-line(.)">
                  <xsl:variable name="this-pos" select="position()"/>
                  <xsl:variable name="this-head" select="$these-heads[$this-pos]"/>
                  <xsl:element name="{(replace($this-head, '\W', '-'), 'element-' || string($this-pos))[1]}">
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:for-each>
            </item>

         </xsl:for-each>
      </csv>
   </xsl:function>
   
   <xsl:function name="tan:tokenize-csv-line" as="xs:string*">
      <!-- Input: a line of csv -->
      <!-- Output, the line parsed as individual items -->
      <xsl:param name="csv-line" as="xs:string?"/>
      <xsl:variable name="these-codepoints" select="string-to-codepoints($csv-line)"/>
      <xsl:variable name="max-codepoint" select="max(($these-codepoints, 192))"/>
      <xsl:variable name="unique-codepoint" select="codepoints-to-string($max-codepoint + 1)"/>
      <xsl:variable name="quote-regex" as="xs:string">"([^"]+?)"</xsl:variable>
      <xsl:variable name="pass-1" as="xs:string*">
         <xsl:analyze-string select="$csv-line" regex="{$quote-regex}">
            <xsl:matching-substring>
               <xsl:value-of select="replace(regex-group(1), ',', $unique-codepoint)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
               <xsl:value-of select="."/>
            </xsl:non-matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:for-each select="tokenize(string-join($pass-1), ',')">
         <xsl:value-of select="replace(., $unique-codepoint, ',')"/>
      </xsl:for-each>
   </xsl:function>
   
   <xsl:function name="tan:jsonxmlmap-to-xml" as="item()*">
      <!-- Input: any result of json-to-xml() -->
      <!-- Output: the fragment with <map> <array> and <string> changed to meaningful names -->
      <xsl:param name="json-to-xml-result" as="item()*"/>
      <xsl:apply-templates select="$json-to-xml-result" mode="jsonxmlmap-to-xml"/>
   </xsl:function>
   <xsl:template match="*" mode="jsonxmlmap-to-xml">
      <xsl:element name="{name(.)}" namespace="">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="*[@key]" mode="jsonxmlmap-to-xml">
      <xsl:element name="{@key}">
         <xsl:copy-of select="* except @key"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:element>
   </xsl:template>
   
   <xsl:variable name="latest-as-xml" as="element()"
      select="tan:csv-to-xml($latest-stat[1], $latest-stat[position() gt 1])"/>
   
   
   <xsl:variable name="latest-by-countries-normalized" as="element()">
      <xsl:apply-templates select="$latest-as-xml" mode="add-country-stats"/>
   </xsl:variable>
   
   <xsl:template match="item" mode="add-country-stats">
      <xsl:variable name="johns-hopkins-country-name" select="Country-Region"/>
      <xsl:variable name="other-data-set-country-preferred-name" select="$country-name-aliases/country[name = $johns-hopkins-country-name]/name[1]"/>
      <xsl:variable name="this-country-name" select="($other-data-set-country-preferred-name, $johns-hopkins-country-name)[1]"/>
      <xsl:variable name="this-country-population"
         select="$country-populations/array/map[country = $this-country-name]/population[1]"/>
      <xsl:variable name="this-country-language"
         select="$country-languages/array/map[country = $this-country-name]/language"/>
      <xsl:variable name="this-country-government-type"
         select="$country-government-type/array/map[country = $this-country-name]/government"/>
      <xsl:variable name="this-country-avg-male-height"
         select="$country-avg-male-height/array/map[country = $this-country-name]/height"/>
      <xsl:variable name="this-country-elevation"
         select="$country-elevation/array/map[country = $this-country-name]/elevation"/>
      <xsl:variable name="this-country-surface-area"
         select="$country-surface-area/array/map[country = $this-country-name]/area"/>
      <xsl:variable name="this-country-yearly-average-temperature"
         select="$country-yearly-average-temperature/array/map[country = $this-country-name]/temperature"/>
      <xsl:variable name="this-country-religion"
         select="$country-religion/array/map[country = $this-country-name]/religion"/>
      <xsl:variable name="this-country-life-expectancy"
         select="$country-life-expectancy/array/map[country = $this-country-name]/expectancy"/>
      <xsl:variable name="this-country-landlocked"
         select="$country-landlocked/array/map[country = $this-country-name]/landlocked"/>
      <xsl:copy>
         <xsl:apply-templates mode="#current">
            <xsl:with-param name="country-name" select="$this-country-name"/>
         </xsl:apply-templates>
         <population>
            <xsl:value-of select="$this-country-population"/>
         </population>
         <xsl:copy-of select="$this-country-language"/>
         <xsl:if test="not(exists($this-country-language))">
            <language/>
         </xsl:if>
         <xsl:copy-of select="$this-country-government-type"/>
         <xsl:if test="not(exists($this-country-government-type))">
            <government/>
         </xsl:if>
         <xsl:copy-of select="$this-country-avg-male-height"/>
         <xsl:if test="not(exists($this-country-avg-male-height))">
            <height/>
         </xsl:if>
         <xsl:copy-of select="$this-country-elevation"/>
         <xsl:if test="not(exists($this-country-elevation))">
            <elevation/>
         </xsl:if>
         <xsl:copy-of select="$this-country-surface-area"/>
         <xsl:if test="not(exists($this-country-surface-area))">
            <area/>
         </xsl:if>
         <xsl:copy-of select="$this-country-yearly-average-temperature"/>
         <xsl:if test="not(exists($this-country-yearly-average-temperature))">
            <temperature/>
         </xsl:if>
         <xsl:copy-of select="$this-country-religion"/>
         <xsl:if test="not(exists($this-country-religion))">
            <religion/>
         </xsl:if>
         <xsl:copy-of select="$this-country-life-expectancy"/>
         <xsl:if test="not(exists($this-country-life-expectancy))">
            <expectancy/>
         </xsl:if>
         <xsl:copy-of select="$this-country-landlocked"/>
         <xsl:if test="not(exists($this-country-landlocked))">
            <landlocked/>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="Country-Region" mode="add-country-stats">
      <xsl:param name="country-name"/>
      <xsl:copy>
         <xsl:value-of select="($country-name, .)[1]"/>
      </xsl:copy>
   </xsl:template>
   
   
   <xsl:variable name="latest-by-country" as="element()">
      <xsl:apply-templates select="$latest-by-countries-normalized" mode="group-by-country"/>
   </xsl:variable>
   
   <xsl:template match="*" mode="group-by-country">
      <xsl:copy>
         <xsl:for-each-group select="*" group-by="*[name(.) = $group-by-what-element]">
            <xsl:variable name="this-country-name" select="current-grouping-key()"/>
            <xsl:variable name="total-confirmed"
               select="
                  sum(for $i in current-group()/Confirmed
                  return
                     xs:integer($i))"
            />
            <xsl:variable name="total-deaths"
               select="
                  sum(for $i in current-group()/Deaths
                  return
                     xs:integer($i))"
            />
            <xsl:variable name="total-recovered"
               select="
                  sum(for $i in current-group()/Recovered
                  return
                     xs:integer($i))"
            />
            <xsl:variable name="these-population-items" as="xs:integer*">
               <xsl:for-each-group select="current-group()" group-by="Country-Region">
                  <xsl:variable name="these-pops" select="current-group()/population[string-length(.) gt 0]"/>
                  <xsl:if test="exists($these-pops)">
                     <xsl:sequence select="xs:integer($these-pops[1])"/>
                  </xsl:if>
               </xsl:for-each-group> 
            </xsl:variable>
            <xsl:variable name="this-group-population" as="xs:integer?"
               select="sum($these-population-items)"/>
            <group>
               <xsl:element name="grouped-by-{$group-by-what-element}">
                  <xsl:value-of select="current-grouping-key()"/>
               </xsl:element>
               <items>
                  <xsl:copy-of select="current-group()"/>
               </items>
               <Confirmed><xsl:value-of select="$total-confirmed"/></Confirmed>
               <Deaths><xsl:value-of select="$total-deaths"/></Deaths>
               <Recovered><xsl:value-of select="$total-recovered"/></Recovered>
               <population><xsl:value-of select="$this-group-population"/></population>
               <confirmed-per-mil>
                  <xsl:if test="$this-group-population gt 0">
                     <xsl:value-of select="format-number($total-confirmed div $this-group-population * 1000000, '0.00')"/>
                  </xsl:if>
               </confirmed-per-mil>
               <deaths-per-mil>
                  <xsl:if test="$this-group-population gt 0">
                     <xsl:value-of select="format-number($total-deaths div $this-group-population * 1000000, '0.00')"/>
                  </xsl:if>
               </deaths-per-mil>
               <recovered-per-mil>
                  <xsl:if test="$this-group-population gt 0">
                     <xsl:value-of select="format-number($total-recovered div $this-group-population * 1000000, '0.00')"/>
                  </xsl:if>
               </recovered-per-mil>
            </group>
         </xsl:for-each-group> 
      </xsl:copy>
   </xsl:template>
   
   <xsl:variable name="template.html" select="doc('template.html')" as="document-node()?"/>
   <xsl:variable name="new-page" as="document-node()?">
      <xsl:apply-templates select="$template.html" mode="build-new-page"/>
   </xsl:variable>
   
   <xsl:param name="columns-of-interest" as="xs:integer*" select="1 to 200"/>
   
   <xsl:template match="h:h1" mode="build-new-page">
      <xsl:copy-of select="."/>
      <div xmlns="http://www.w3.org/1999/xhtml">
         <xsl:value-of select="'Built ' || string(current-dateTime()) || ' from data at ' || $latest-covid-stats-uri"/>
      </div>
   </xsl:template>
   <xsl:template match="h:table/h:thead/h:tr" mode="build-new-page">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:for-each select="$latest-by-country/*[1]/*[position() = $columns-of-interest]">
            <td xmlns="http://www.w3.org/1999/xhtml">
               <xsl:value-of select="replace(name(.), '\W', ' ')"/>
            </td>
         </xsl:for-each>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="h:tbody" mode="build-new-page">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:for-each select="$latest-by-country/group">
            <xsl:sort select="number(confirmed-per-mil)" order="descending"/>
            <xsl:apply-templates select="." mode="#current"/>
         </xsl:for-each>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="group" mode="build-new-page">
      <tr xmlns="http://www.w3.org/1999/xhtml">
         <xsl:apply-templates select="*[position() = $columns-of-interest]" mode="#current"/>
      </tr>
   </xsl:template>
   <xsl:template match="group/*[not(*)]" mode="build-new-page">
      <td xmlns="http://www.w3.org/1999/xhtml">
         <xsl:value-of select="."/>
      </td>
   </xsl:template>
   <xsl:template match="group/items" mode="build-new-page">
      <td xmlns="http://www.w3.org/1999/xhtml">
         <!--<xsl:apply-templates mode="#current"/>-->
         <xsl:value-of select="count(item)"/>
      </td>
   </xsl:template>
   <!-- next two templates don't take effect because the above template reduces the datum to a count -->
   <xsl:template match="group/items/item" mode="build-new-page">
      <div xmlns="http://www.w3.org/1999/xhtml">
         <xsl:apply-templates select="(Province-State, Country-Region, language, government)[not(name(.) = $group-by-what-element)]" mode="#current"/>
      </div>
   </xsl:template>
   <xsl:template match="group/items/item/*" mode="build-new-page">
      <span xmlns="http://www.w3.org/1999/xhtml">
         <xsl:apply-templates mode="#current"/>
      </span>
   </xsl:template>
   
   
   <!--<xsl:variable name="covid-countries-without-match-in-other-country-dataset" as="element()*"
      select="$latest-by-country/group/Country-Region[not(. = $country-populations/array/map/country)]"/>-->
   
   <xsl:variable name="country-name-aliases" as="element()">
      <country-names>
         <country>
            <name>United States</name>
            <name>US</name>
         </country>
         <country>
            <name>South Korea</name>
            <name>Korea, South</name>
         </country>
         <country>
            <name>Czech Republic</name>
            <name>Czechia</name>
         </country>
         <country>
            <name>Russian Federation</name>
            <name>Russia</name>
         </country>
         <country>
            <name>Taiwan</name>
            <name>Taiwan*</name>
         </country>
         <country>
            <name>Congo</name>
            <name>Congo (Kinshasa)</name>
            <name>Congo (Brazzaville)</name>
         </country>
         <country>
            <name>The Democratic Republic of Congo</name>
            <name>Republic of the Congo</name>
         </country>
         <country>
            <name>Ivory Coast</name>
            <name>Cote d'Ivoire</name>
         </country>
         <country>
            <name>Bahamas</name>
            <name>Bahamas, The</name>
            <name>The Bahamas</name>
         </country>
         <country>
            <name>Cape Verde</name>
            <name>Cabo Verde</name>
         </country>
         <country>
            <name>Gambia</name>
            <name>The Gambia</name>
            <name>Gambia, The</name>
         </country>
         <country>
            <name>Fiji Islands</name>
            <name>Fiji</name>
         </country>
         <country>
            <name>Holy See (Vatican City State)</name>
            <name>Holy See</name>
         </country>
         <country>
            <name></name>
            <name></name>
         </country>
      </country-names>
   </xsl:variable>
   
   
   <xsl:param name="output-uri-resolved" select="resolve-uri($group-by-what-element || '.html', static-base-uri())"/>
   <xsl:template match="/">
      <analysis>
         <latest-uri><xsl:value-of select="$latest-covid-stats-uri"/></latest-uri>
         <lax><xsl:copy-of select="$latest-as-xml"/></lax>
         <xml-norm><xsl:copy-of select="$latest-by-countries-normalized"/></xml-norm>
         <country><xsl:copy-of select="$latest-by-country"/></country>
         <!--<pops><xsl:copy-of select="$country-populations"/></pops>-->
         <!--<orphans><xsl:copy-of select="$covid-countries-without-match-in-other-country-dataset"/></orphans>-->
      </analysis>
      <xsl:result-document href="{$output-uri-resolved}">
         <xsl:message select="'saving html to ' || $output-uri-resolved"/>
         <xsl:sequence select="$new-page"/>
      </xsl:result-document>
   </xsl:template>
</xsl:stylesheet>
