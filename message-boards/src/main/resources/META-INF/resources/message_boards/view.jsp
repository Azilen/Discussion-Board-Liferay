<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
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
<%@page import="java.util.Collections"%>
<%@page import="com.liferay.portal.kernel.util.ListUtil"%>
<%@page import="javax.portlet.RenderRequest"%>
<%@page import="com.azilen.message.boards.list.CustomThreadCategoryList"%>
<%@page import="com.liferay.portal.kernel.util.GetterUtil"%>
<%@page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@page import="com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil"%>
<%@page import="com.liferay.message.boards.web.constants.MBPortletKeys"%>
<%@page import="com.liferay.portal.kernel.servlet.SessionErrors"%>
<%@page import="com.liferay.message.boards.kernel.service.MBThreadLocalServiceUtil"%>
<%@page import="com.liferay.message.boards.kernel.model.MBThread"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil"%>
<%@page import="java.util.List"%>
<%@page import="com.liferay.message.boards.kernel.model.MBCategory"%>
<%@page import="javax.portlet.PortletPreferences"%>
<%@page import="com.liferay.portal.kernel.service.PortletPreferencesLocalServiceUtil"%>
<%@ include file="/message_boards/init.jsp" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
 <liferay-theme:defineObjects />
<%
String redirect = ParamUtil.getString(request, "redirect");

String mvcRenderCommandName = ParamUtil.getString(request, "mvcRenderCommandName", "/message_boards/view");
//Custom code for discussion board
String mvcSearchCommandName=ParamUtil.getString(request, "mvcRenderCommandName");
MBCategory category = (MBCategory)request.getAttribute(WebKeys.MESSAGE_BOARDS_CATEGORY);
long categoryId = MBUtil.getCategoryId(request, category);

if(mvcSearchCommandName.equalsIgnoreCase("/message_boards/search")){
	categoryId=GetterUtil.getLong(request.getAttribute("categoryId"));
}
Set<Long> categorySubscriptionClassPKs = null;
Set<Long> threadSubscriptionClassPKs = null;
if (themeDisplay.isSignedIn()) {
	categorySubscriptionClassPKs = MBUtil.getCategorySubscriptionClassPKs(user.getUserId());
	threadSubscriptionClassPKs = MBUtil.getThreadSubscriptionClassPKs(user.getUserId());
}

long groupThreadsUserId = ParamUtil.getLong(request, "groupThreadsUserId");

String assetTagName = ParamUtil.getString(request, "tag");

boolean useAssetEntryQuery = Validator.isNotNull(assetTagName);

PortletURL portletURL = renderResponse.createRenderURL();

String keywords = ParamUtil.getString(request, "keywords");

if (Validator.isNotNull(keywords)) {
	portletURL.setParameter("keywords", keywords);
}

request.setAttribute("view.jsp-categorySubscriptionClassPKs", categorySubscriptionClassPKs);
request.setAttribute("view.jsp-threadSubscriptionClassPKs", threadSubscriptionClassPKs);

request.setAttribute("view.jsp-categoryId", categoryId);
request.setAttribute("view.jsp-portletURL", portletURL);
request.setAttribute("view.jsp-viewCategory", Boolean.TRUE.toString());

//Custom code for display selected category for discussion board
MBCategory selectedCategory = null;
PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), MBPortletKeys.MESSAGE_BOARDS);
String preferenceCategory=preferences.getValue("categoryName", "-1");
pageContext.setAttribute("preferenceCategory",preferenceCategory,PageContext.SESSION_SCOPE);
if(categoryId == 0){
	long parentCategoryId=0;
	long preferenceCategoryID	=	Long.parseLong(preferences.getValue("categoryID", "-1"));
	if(preferenceCategoryID != -1){
		try{
			selectedCategory = MBCategoryLocalServiceUtil.getCategory(preferenceCategoryID);	
		}catch(Exception e){
			_log.error("Exception :=>"+e);
		}
	}
	if(selectedCategory != null ){
		categoryId=selectedCategory.getCategoryId();	
	}
}
else{
	
	 selectedCategory=(MBCategory)request.getAttribute("selectedCategory");
}
pageContext.setAttribute("selectedCategory",selectedCategory,PageContext.SESSION_SCOPE);
MBListDisplayContext mbListDisplayContext;
if(selectedCategory != null){
 mbListDisplayContext = mbDisplayContextProvider.getMbListDisplayContext(request, response, selectedCategory.getCategoryId());
}
else{ 
	mbListDisplayContext = mbDisplayContextProvider.getMbListDisplayContext(request, response, categoryId);
 } 
if(selectedCategory != null){
	 session.setAttribute("selectedCategoryName", selectedCategory.getName());	 
	 session.setAttribute("selectedCategory", selectedCategory);
}

String errorMessage=StringPool.BLANK;
if(request.getAttribute("errorMessage") != null){
	errorMessage=(String)request.getAttribute("errorMessage");	
}

pageContext.setAttribute("errorMessage",errorMessage,PageContext.SESSION_SCOPE);
portletURL.setParameter("mvcRenderCommandName", mvcRenderCommandName);
portletURL.setParameter("mbCategoryId", String.valueOf(categoryId));
request.setAttribute("preference", preferences);
request.setAttribute("groupId", themeDisplay.getScopeGroupId());
%>

 <%if(errorMessage.equalsIgnoreCase("showMessage")){ %> 
	<div style="width: 100%;background-color: #f1d1d8; border-color: #e5abb4;padding:15px;">
		<strong style="color: #d77c8a;">You do not set this category in message board preference for this page</strong>
	</div>
 <%}else{ %>
<portlet:actionURL name="/message_boards/edit_category" var="restoreTrashEntriesURL">
	<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.RESTORE %>" />
</portlet:actionURL>

<liferay-trash:undo
	portletURL="<%= restoreTrashEntriesURL %>"
/>
<liferay-util:include page='<%= "/message_boards/top_links.jsp" %>' servletContext="<%= application %>">
	<liferay-util:param name="categoryId" value="<%= String.valueOf(categoryId) %>" />
</liferay-util:include>
 
<c:choose>
	<c:when test="<%= useAssetEntryQuery %>">
		<liferay-ui:categorization-filter
			assetType="threads"
			portletURL="<%= portletURL %>"
		/>

		<%@ include file="/message_boards/view_threads.jspf" %>
	</c:when>
	<c:when test='<%= mbListDisplayContext.isShowSearch() || mvcRenderCommandName.equals("/message_boards/view") || mvcRenderCommandName.equals("/message_boards/view_category") || mbListDisplayContext.isShowMyPosts() || mbListDisplayContext.isShowRecentPosts() %>'>

		<%
		SearchContainer entriesSearchContainer = new SearchContainer(renderRequest, null, null, "cur1", 0, SearchContainer.DEFAULT_DELTA, portletURL, null, "there-are-no-threads-nor-categories");
		entriesSearchContainer.setId("mbEntries");
		mbListDisplayContext.populateResultsAndTotal(entriesSearchContainer);
	
		%>
		
		<c:choose>
			<c:when test='<%= mvcRenderCommandName.equals("/message_boards/search") || mvcRenderCommandName.equals("/message_boards/view") || mvcRenderCommandName.equals("/message_boards/view_category") %>'>
				<div class="main-content-body">
					<c:if test="<%= mbListDisplayContext.isShowSearch() %>">
						<liferay-ui:header
							backURL="<%= redirect %>"
							title="search"
						/>
					</c:if>
					<%
							if(mbListDisplayContext.isShowSearch()){
								List<MBThread> threads=CustomThreadCategoryList.getSearchResults(request, categoryId,entriesSearchContainer);
								request.setAttribute("totalSize", threads.size());
								request.setAttribute("pageType", "Search");
								if(!threads.isEmpty()){
										request.setAttribute("resultsList", threads);
								 }
								else{ 
									request.setAttribute("resultsList", null);
									request.setAttribute("emptyMessage", "There are no threads");
								 } 
							}
							else{
								List<Object> subCategories=new ArrayList<>();
								 if(selectedCategory != null){
									 subCategories=CustomThreadCategoryList.getMBSubCategories(request, selectedCategory.getCategoryId());
								}
								else{
									 subCategories=CustomThreadCategoryList.getMBSubCategories(request, 0);
								} 
								 request.setAttribute("totalSize", subCategories.size());
								if(!subCategories.isEmpty()){
									request.setAttribute("resultsList", subCategories);
									 request.setAttribute("pageType", "");
								}
								else{
									request.setAttribute("resultsList", null);
									request.setAttribute("emptyMessage", "There are no threads nor categories");
								}
							}
							
					 %> 
					<%
					boolean showAddCategoryButton = MBCategoryPermission.contains(permissionChecker, scopeGroupId, categoryId, ActionKeys.ADD_CATEGORY);
					boolean showAddMessageButton = MBCategoryPermission.contains(permissionChecker, scopeGroupId, categoryId, ActionKeys.ADD_MESSAGE);
					boolean showPermissionsButton = MBPermission.contains(permissionChecker, scopeGroupId, ActionKeys.PERMISSIONS);

					if (showAddMessageButton && !themeDisplay.isSignedIn()) {
						if (!allowAnonymousPosting) {
							showAddMessageButton = false;
						}
					}
					%>

					<c:if test="<%= showAddCategoryButton || showAddMessageButton || showPermissionsButton %>">
						<aui:button-row>
							<c:if test="<%= showAddCategoryButton %>">
								<portlet:renderURL var="editCategoryURL">
									<portlet:param name="mvcRenderCommandName" value="/message_boards/edit_category" />
									<portlet:param name="redirect" value="<%= currentURL %>" />
									<portlet:param name="parentCategoryId" value="<%= String.valueOf(categoryId) %>" />
								</portlet:renderURL>

								<aui:button href="<%= editCategoryURL %>" value='<%= (category == null) ? "add-category[message-board]" : "add-subcategory[message-board]" %>' />
							</c:if>

							<c:if test="<%= showAddMessageButton %>">
								<portlet:renderURL var="editMessageURL">
									<portlet:param name="mvcRenderCommandName" value="/message_boards/edit_message" />
									<portlet:param name="redirect" value="<%= currentURL %>" />
									<portlet:param name="mbCategoryId" value="<%= String.valueOf(categoryId) %>" />
								</portlet:renderURL>

								<aui:button href="<%= editMessageURL %>" value="post-new-thread" />
							</c:if>

							<c:if test="<%= showPermissionsButton %>">

								<%
								String modelResource = "com.liferay.message.boards";
								String modelResourceDescription = themeDisplay.getScopeGroupName();
								String resourcePrimKey = String.valueOf(scopeGroupId);

								if (category != null) {
									modelResource = MBCategory.class.getName();
									modelResourceDescription = category.getName();
									resourcePrimKey = String.valueOf(category.getCategoryId());
								}
								%>

								<liferay-security:permissionsURL
									modelResource="<%= modelResource %>"
									modelResourceDescription="<%= HtmlUtil.escape(modelResourceDescription) %>"
									resourcePrimKey="<%= resourcePrimKey %>"
									var="permissionsURL"
									windowState="<%= LiferayWindowState.POP_UP.toString() %>"
								/>

								<aui:button href="<%= permissionsURL %>" useDialog="<%= true %>" value="permissions" />
							</c:if>
						</aui:button-row>

						<%@ include file="/message_boards/category_subscriptions.jspf" %>
					</c:if>
					<c:if test="<%= category != null %>">
						<div class="category-subscription category-subscription-types">
							<c:if test="<%= enableRSS %>">
								<liferay-ui:rss
									delta="<%= rssDelta %>"
									displayStyle="<%= rssDisplayStyle %>"
									feedType="<%= rssFeedType %>"
									url="<%= MBUtil.getRSSURL(plid, category.getCategoryId(), 0, 0, themeDisplay) %>"
								/>
							</c:if>

							<c:if test="<%= MBCategoryPermission.contains(permissionChecker, category, ActionKeys.SUBSCRIBE) && (mbGroupServiceSettings.isEmailMessageAddedEnabled() || mbGroupServiceSettings.isEmailMessageUpdatedEnabled()) %>">
								<c:choose>
									<c:when test="<%= (categorySubscriptionClassPKs != null) && categorySubscriptionClassPKs.contains(category.getCategoryId()) %>">
										<portlet:actionURL name="/message_boards/edit_category" var="unsubscribeURL">
											<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.UNSUBSCRIBE %>" />
											<portlet:param name="redirect" value="<%= currentURL %>" />
											<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
										</portlet:actionURL>

										<liferay-ui:icon
											iconCssClass="icon-remove-sign"
											label="<%= true %>"
											message="unsubscribe"
											url="<%= unsubscribeURL %>"
										/>
									</c:when>
									<c:otherwise>
										<portlet:actionURL name="/message_boards/edit_category" var="subscribeURL">
											<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.SUBSCRIBE %>" />
											<portlet:param name="redirect" value="<%= currentURL %>" />
											<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
										</portlet:actionURL>
										<liferay-ui:icon
											iconCssClass="icon-ok-sign"
											label="<%= true %>"
											message="subscribe"
											url="<%= subscribeURL %>"
										/>
									</c:otherwise>
								</c:choose>
							</c:if>
						</div>

						<%
						long parentCategoryId = category.getParentCategoryId();
						String parentCategoryName = LanguageUtil.get(request, "message-boards-home");

						if (!category.isRoot()) {
							MBCategory parentCategory = MBCategoryLocalServiceUtil.getCategory(parentCategoryId);

							parentCategoryId = parentCategory.getCategoryId();
							parentCategoryName = parentCategory.getName();
						}
						%>
					
								
						<portlet:renderURL var="backURL">
							<c:choose>
								
								<c:when test="<%= parentCategoryId == MBCategoryConstants.DEFAULT_PARENT_CATEGORY_ID %>">
									<portlet:param name="mvcRenderCommandName" value="/message_boards/view" />
									
								</c:when>
								<c:otherwise>
									<portlet:param name="mvcRenderCommandName" value="/message_boards/view_category" />
									<portlet:param name="mbCategoryId" value="<%= String.valueOf(parentCategoryId) %>" />
									
								</c:otherwise>
							</c:choose>
						</portlet:renderURL>
						<%if(!preferenceCategory.equalsIgnoreCase(category.getName())){ %>
						<liferay-ui:header
							backLabel="<%= parentCategoryName %>"
							backURL="<%= backURL.toString() %>"
							localizeTitle="<%= false %>"
							title="<%=selectedCategory.getName()%>"
						/>
						
						<%} %>
					</c:if>

					<%
					request.setAttribute("view.jsp-displayStyle", "descriptive");
					request.setAttribute("view.jsp-entriesSearchContainer", entriesSearchContainer);
					%>

					<liferay-util:include page='<%= "/message_boards_admin/view_entries.jsp" %>' servletContext="<%= application %>" />
					<%-- <liferay-util:include page='<%= "/message_boards/customView_entries.jsp" %>' servletContext="<%= application %>" /> --%>

					<%
					if (category != null) {
						PortalUtil.setPageSubtitle(category.getName(), request);
						PortalUtil.setPageDescription(category.getDescription(), request);
					}
					%>

				</div>

			</c:when>
		
			<c:when test="<%= mbListDisplayContext.isShowMyPosts() || mbListDisplayContext.isShowRecentPosts() %>">
				<div class="main-content-body">

					<%
					if (mbListDisplayContext.isShowMyPosts() && themeDisplay.isSignedIn()) {
						groupThreadsUserId = user.getUserId();
					}

					if (groupThreadsUserId > 0) {
						portletURL.setParameter("groupThreadsUserId", String.valueOf(groupThreadsUserId));
					}
					%>

					<c:if test="<%= mbListDisplayContext.isShowMyPosts() && (groupThreadsUserId > 0) %>">
						<div class="alert alert-info">
							<liferay-ui:message key="filter-by-user" />: <%= HtmlUtil.escape(PortalUtil.getUserName(groupThreadsUserId, StringPool.BLANK)) %>
						</div>
					</c:if>

					<%
					request.setAttribute("view.jsp-displayStyle", "descriptive");
					request.setAttribute("view.jsp-entriesSearchContainer", entriesSearchContainer);
					%>
					
					<c:if test="<%= enableRSS && mbListDisplayContext.isShowRecentPosts() %>">
						<liferay-ui:rss
							delta="<%= rssDelta %>"
							displayStyle="<%= rssDisplayStyle %>"
							feedType="<%= rssFeedType %>"
							message="subscribe-to-recent-posts"
							url="<%= MBUtil.getRSSURL(plid, 0, 0, groupThreadsUserId, themeDisplay) %>"
						/>
					</c:if>
					<%
					//Custom list for recent posts and my posts
					if (mbListDisplayContext.isShowRecentPosts()) {
						List<MBThread> recentPosts=CustomThreadCategoryList.getRecentPosts(request);
						request.setAttribute("totalSize", recentPosts.size());
						if(!recentPosts.isEmpty()){
							request.setAttribute("resultsList", recentPosts);
							request.setAttribute("pageType", "Posts");
						}
					 else{
							request.setAttribute("resultsList", null);
							request.setAttribute("emptyMessage", "There are no recent posts");
					 }
						
					}
					else {
						List<MBThread> myPosts=CustomThreadCategoryList.getMyPosts(request);
						request.setAttribute("totalSize", myPosts.size());
						if(!myPosts.isEmpty()){
								request.setAttribute("resultsList", myPosts);
								request.setAttribute("pageType", "Posts");
						}				
						 else{
							request.setAttribute("resultsList", null);
							request.setAttribute("emptyMessage", "You do not have any posts");
						 }
						
					}
					%>
					<liferay-util:include page='<%= "/message_boards_admin/view_entries.jsp" %>' servletContext="<%= application %>">
						<liferay-util:param name="showBreadcrumb" value="<%= Boolean.FALSE.toString() %>" />
					</liferay-util:include>

					<%
					String pageSubtitle = null;

					if (mbListDisplayContext.isShowMyPosts()) {
						pageSubtitle = "my-posts";
					}
					else if (mbListDisplayContext.isShowRecentPosts()) {
						pageSubtitle = "recent-posts";
					}

					PortalUtil.setPageSubtitle(LanguageUtil.get(request, StringUtil.replace(pageSubtitle, CharPool.UNDERLINE, CharPool.DASH)), request);
					PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(request, TextFormatter.format(pageSubtitle, TextFormatter.O)), portletURL.toString());
					%>

				</div>
			</c:when>
		</c:choose>
	</c:when>
	<c:when test='<%= mvcRenderCommandName.equals("/message_boards/view_my_subscriptions") %>'>

		 <%
		if (themeDisplay.isSignedIn()) {
			groupThreadsUserId = user.getUserId();
		}

		if (groupThreadsUserId > 0) {
			portletURL.setParameter("groupThreadsUserId", String.valueOf(groupThreadsUserId));
		}
		MBCategoryDisplay categoryDisplay = new MBCategoryDisplayImpl(scopeGroupId, 0);
		%>
		
		  <div class="main-content-body">
		  <%
				int size=CustomThreadCategoryList.getSubscribedCategoriesList(request).size();  
		  %>
			<liferay-ui:search-container
				curParam="cur1"
				emptyResultsMessage="you-are-not-subscribed-to-any-categories"
				headerNames="category,categories,threads,posts"
				iteratorURL="<%= portletURL %>"
				total="<%=size%>"
				delta="20"
			>
				<liferay-ui:search-container-results>
						<%
							//Custom list for subscribed categories
							List<MBCategory> categoryResults = CustomThreadCategoryList.getSubscribedCategoriesList(request);
							total = categoryResults.size();
							pageContext.setAttribute("total", total);
							if(!categoryResults.isEmpty()){
								results = ListUtil.subList(categoryResults,searchContainer.getStart(),searchContainer.getEnd());
								pageContext.setAttribute("results", results);
							}
							else{ 
								pageContext.setAttribute("results", null);
							 } 
						%>
				</liferay-ui:search-container-results>
			
				<liferay-ui:search-container-row
					className="com.liferay.message.boards.kernel.model.MBCategory"
					escapedModel="<%= true %>"
					keyProperty="categoryId"
					modelVar="curCategory"
				>
					<liferay-ui:search-container-row-parameter name="categorySubscriptionClassPKs" value="<%= categorySubscriptionClassPKs %>" />

					<liferay-portlet:renderURL varImpl="rowURL">
						<portlet:param name="mvcRenderCommandName" value="/message_boards/view_category" />
						<portlet:param name="mbCategoryId" value="<%= String.valueOf(curCategory.getCategoryId()) %>" />
					</liferay-portlet:renderURL>

					 <%@ include file="/message_boards/subscribed_category_columns.jspf" %> 
				</liferay-ui:search-container-row>

				<liferay-ui:search-iterator type="more"/>
			</liferay-ui:search-container>

			 <%@ include file="/message_boards/view_threads.jspf" %>  
			<%
			PortalUtil.setPageSubtitle(LanguageUtil.get(request, StringUtil.replace("my-subscriptions", CharPool.UNDERLINE, CharPool.DASH)), request);
			PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(request, TextFormatter.format("my-subscriptions", TextFormatter.O)), portletURL.toString());
			%>

		</div>  
	</c:when> 
</c:choose>
 <%} %> 
<%!
private static Log _log = LogFactoryUtil.getLog("com_liferay_message_boards_web.message_boards.view_jsp");
%>