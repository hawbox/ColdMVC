<cfif thisTag.executionMode eq "start">
	<cfoutput>
		#coldmvc.html.tr(argumentCollection=attributes)#
	</cfoutput>
<cfelse>
	</tr>
</cfif>