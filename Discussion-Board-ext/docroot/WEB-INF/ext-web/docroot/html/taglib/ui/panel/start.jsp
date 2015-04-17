<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/taglib/ui/panel/init.jsp" %>
<script type="text/javascript"> 

function <%=id.toString()%>onCollapseClick()
{	
	//alert("<%=id.toString()%>collapse_MB_ID");
	if($("#<%=id.toString()%>collapse_MB_ID").hasClass('collapse-icon_CT_MB')){
		$("#<%=id.toString()%>collapse_MB_ID").removeClass('collapse-icon_CT_MB');
		$("#<%=id.toString()%>collapse_MB_ID").addClass('expand-icon_CT_MB');
	} else {		
		$("#<%=id.toString()%>collapse_MB_ID").removeClass('expand-icon_CT_MB');
		$("#<%=id.toString()%>collapse_MB_ID").addClass('collapse-icon_CT_MB');
	};	
}


</script>

 
 <%
 	String styleForPanel="";
 	if(id!=null && (id.equals("messageBoardsCategoriesPanel")||id.equals("messageBoardsThreadsPanel")||id.equals("messageBoardsTopPostersPanel")||id.equals("messageBoardsMailingListPanel")||id.equals("mbMessageAttachmentsPanel")||id.equals("mbMessageCategorizationPanel")||id.equals("mbMessageAssetLinksPanel")||id.equals("messageBoardsGeneralStatisticsPanel")))
 		styleForPanel="border: 1px solid #F4F4F4; ";
 	if(id.equals("mbMessageCategorizationPanel"))
 		styleForPanel+="padding-bottom: 30px;";
 		
 %>
<div class="accordion-group <%= cssClass %>" id="<%= id %>" style="<%=styleForPanel%>">
	<div class="accordion-heading <%= headerCssClass %>" data-persist-id="<%= persistState ? id : StringPool.BLANK %>">
		<div class="accordion-toggle" onclick="<%=id.toString()%>onCollapseClick();">
			<c:if test="<%= Validator.isNotNull(iconCssClass) %>">
				<i class="<%= iconCssClass %>"></i>
			</c:if>

			<%
				
				if(id!=null && (id.equals("messageBoardsCategoriesPanel")||id.equals("messageBoardsThreadsPanel")||id.equals("messageBoardsTopPostersPanel")||id.equals("messageBoardsMailingListPanel")||id.equals("mbMessageAttachmentsPanel")||id.equals("mbMessageCategorizationPanel")||id.equals("mbMessageAssetLinksPanel")||id.equals("messageBoardsGeneralStatisticsPanel")))
				{	
			%>
					<span class="title-text">
						<liferay-ui:message key="<%= title %>" />
					</span>
					
					
					<i class="collapse-icon_CT_MB" id="<%=id.toString()%>collapse_MB_ID" ></i>
			<%					
				}
				else
				{
			%>
				<span class="title-text">
					<liferay-ui:message key="<%= title %>" />
				</span>
			<%		
				}
			%>

			<c:if test="<%= Validator.isNotNull(helpMessage) %>">
				<liferay-ui:icon-help message="<%= helpMessage %>" />
			</c:if>
		</div>
	</div>
	<div class="<%= contentCssClass %>" id="<%= id %>Content">
		<div class="accordion-inner">