<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/database">
    <html>
      <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.no-icons.min.css" rel="stylesheet"/>
      <link href="http://netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css" rel="stylesheet"/>
      <script src="http://code.jquery.com/jquery-1.9.1.min.js"/>
      <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"/>
      <style>
	.bs-docs-example {
	    background-color: #FFFFFF;
	    border: 1px solid #DDDDDD;
	    border-radius: 4px 4px 4px 4px;
	    margin: 15px 0;
	    padding: 39px 19px 14px;
	    position: relative;
	}
	.bs-docs-example:after {
	    background-color: #F5F5F5;
	    border: 1px solid #DDDDDD;
	    border-radius: 4px 0 4px 0;
	    color: #9DA0A4;
	    content: "Default Value";
	    font-size: 12px;
	    font-weight: bold;
	    left: -1px;
	    padding: 3px 7px;
	    position: absolute;
	    top: -1px;
	}
        @page {
	  size: letter;
	  margin: 1in;
	}
      </style>
      <body>
	<div class="container">
	  <div class="row">
	    <div class="span3 bs-docs-sidebar hidden-print">
		<ul class="nav nav-list bs-docs-sidenav" id="nav">
		  <xsl:for-each select="/database/schema">
		    <li class="nav-header">
		      <xsl:value-of select="@table_schema"/> (<xsl:value-of select="@n_tables"/>)
		    </li>
		    <xsl:for-each select="table">
		      <li>
			<a href="{concat('#', translate(../@table_schema, ' ', '_'), '-', translate(@table_name, ' ', '_'))}">
			  <xsl:value-of select="@table_name"/>
			</a>
		      </li>
		    </xsl:for-each>
		  </xsl:for-each>
		</ul>
	    </div>
	    <div class="span9" id="top">
	      <xsl:for-each select="/database/schema">
		<h2><xsl:value-of select="@table_schema"/></h2>
		<xsl:for-each select="table">
		  <section class="table-section" id="{concat(translate(../@table_schema, ' ', '_'), '-', translate(@table_name, ' ', '_'))}">
		    <table class="table table-hover table-condensed" summary="{@table_name}">
                      <caption style="">
			<h3>
			  <xsl:value-of select="concat(@table_name, ' ')"/>
			  <small>
			    (<xsl:value-of select="format-number(@n_rows, '###,###,###')"/>)
			  </small>
			</h3>
		      </caption>
		      <thead>
			<th>Name</th>
			<th>Data Type</th>
			<th><div class="text-center">Nullable?</div></th>
			<th><div class="text-center"># Null</div></th>
			<th><div class="text-center"># Distinct</div></th>
		      </thead>
		      <tbody>
			<xsl:for-each select="column">
			  <tr>
			    <td>
			      <xsl:choose>
				<xsl:when test="@column_default or mcv">
				  <a href="#" title="{@column_default}" data-toggle="modal" data-target="{concat('#', ../../@table_schema, '-', translate(../@table_name, ' ', '_'), '-', translate(@column_name, ' ', '_'))}">
				    <xsl:value-of select="@column_name"/>
				  </a>
				  <div id="{concat(../../@table_schema, '-', translate(../@table_name, ' ', '_'), '-', translate(@column_name, ' ', '_'))}" class="modal hide fade" tabindex="-1" data-keyboard="true">
				    <div class="modal-body">
				      <xsl:if test="mcv">
					<h3><xsl:value-of select="@column_name"/></h3>
					<table class="table table-hover table-condensed">
					  <caption><h4>Most Common Values</h4></caption>
					  <thead>
					    <th><div class="text-center"># Occurs</div></th>
					    <th>Value</th>
					  </thead>
					  <tbody>
					    <xsl:for-each select="mcv">
					      <tr>
						<td>
						  <div class="text-center heat-map" heat-val="{@n}" heat-max="{../../@n_rows}" heat-map="hm-distinct">
						    <xsl:value-of select="format-number(@n, '###,###,###')"/>
						  </div>
						</td>
						<td><xsl:value-of select="."/></td>
					      </tr>
					    </xsl:for-each>
					  </tbody>
					</table>
				      </xsl:if>
				      <xsl:if test="@column_default">
					<div class="bs-docs-example">
					  <xsl:value-of select="@column_default"/>
					</div>
				      </xsl:if>
				    </div>
				  </div>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="@column_name"/>
				</xsl:otherwise>
			      </xsl:choose>
			    </td>
			    <td><xsl:value-of select="@data_type"/></td>
			    <td>
			      <div class="text-center">
				<xsl:choose>
				  <xsl:when test="@is_nullable = 'YES'">
				    <i style="color: rgb(0, 255, 0)" class="icon-ok"/>
				  </xsl:when>
				  <xsl:otherwise>
				    <i style="color: rgb(255, 0, 0)" class="icon-remove"/>
				  </xsl:otherwise>
				</xsl:choose>
			      </div>
			    </td>
			    <td>
			      <div class="text-center heat-map" heat-val="{@n_null}" heat-max="{../@n_rows}" heat-map="hm-null">
			        <xsl:value-of select="format-number(@n_null, '###,###,###')"/>
			      </div>
			    </td>
			    <td>
			      <div class="text-center heat-map" heat-val="{@n_distinct}" heat-max="{../@n_rows}" heat-map="hm-distinct">
			        <xsl:value-of select="format-number(@n_distinct, '###,###,###')"/>
			      </div>
			    </td>
			  </tr>
			</xsl:for-each>
		      </tbody>
		    </table>
		  </section>
	          <small class="pull-right hidden-print"><a href="#top">top</a></small>
		</xsl:for-each>
	      </xsl:for-each>
	    </div>
	  </div>
	</div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet> 
