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

<%@page import="com.liferay.portlet.messageboards.service.MBCategoryLocalServiceUtil"%>
<%@page import="com.liferay.portal.theme.PortletDisplay"%>
<%@page import="javax.portlet.PortletSession"%>

<%@ include file="/html/portlet/message_boards/init.jsp" %>

<%
	SimpleDateFormat dateFormatObj = new SimpleDateFormat("EEE MMM dd, yyyy hh:mm a");
%>

<!-- custom code start-->
<%
			String windowKey = renderRequest.getWindowID();
			windowKey=windowKey.substring(windowKey.indexOf("_"), windowKey.length());
			
			
			
			
			ThemeDisplay themeDisplayObj2= (ThemeDisplay) request.getAttribute(WebKeys.THEME_DISPLAY);
			PortletDisplay portletDisplayObj= themeDisplayObj2.getPortletDisplay();
			String portletId= "86"; // beacuse thr portletId of configuration portlet is 86
			PortletPreferences preferences = PortletPreferencesFactoryUtil.getPortletSetup(request, "86");
			String rootCategoryId=GetterUtil.getString(preferences.getValue(windowKey, "0"));
			
%>

<!-- custom code end-->

<%
String topLink = ParamUtil.getString(request, "topLink", "message-boards-home");

String redirect = ParamUtil.getString(request, "redirect");

MBCategory category = (MBCategory)request.getAttribute(WebKeys.MESSAGE_BOARDS_CATEGORY);

long categoryId = MBUtil.getCategoryId(request, category);
long categoryIdOld=categoryId;
/* custom code start*/
if(rootCategoryId.equals("0"))
{
	session.setAttribute("MBCategoryNameParam", "Message Boards Home");
	session.setAttribute("MBCategoryIdParam", "-1");
}

if(categoryId==0 && (!rootCategoryId.equals("0") && rootCategoryId!=null))
{
	categoryId=Long.parseLong(rootCategoryId);
	category=MBCategoryServiceUtil.getCategory(categoryId);	
	session.setAttribute("MBCategoryNameParam", category.getName());
	session.setAttribute("MBCategoryIdParam", ""+categoryId);
}
/* custom code ends*/

String displayStyle = BeanPropertiesUtil.getString(category, "displayStyle", MBCategoryConstants.DEFAULT_DISPLAY_STYLE);
// just for statisctics can be any type of categroyId
MBCategoryDisplay categoryDisplay = new MBCategoryDisplayImpl(scopeGroupId, categoryId);

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

portletURL.setParameter("struts_action", "/message_boards/view");
portletURL.setParameter("topLink", topLink);
portletURL.setParameter("mbCategoryId", String.valueOf(categoryId));

request.setAttribute("view.jsp-categoryDisplay", categoryDisplay);

request.setAttribute("view.jsp-categorySubscriptionClassPKs", categorySubscriptionClassPKs);
request.setAttribute("view.jsp-threadSubscriptionClassPKs", threadSubscriptionClassPKs);

request.setAttribute("view.jsp-viewCategory", Boolean.TRUE.toString());

request.setAttribute("view.jsp-portletURL", portletURL);
%>

<portlet:actionURL var="undoTrashURL">
	<portlet:param name="struts_action" value="/message_boards/edit_entry" />
	<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.RESTORE %>" />
</portlet:actionURL>

<liferay-ui:trash-undo portletURL="<%= undoTrashURL %>" />

<liferay-util:include page="/html/portlet/message_boards/top_links.jsp" />

<c:choose>
	<c:when test="<%= useAssetEntryQuery %>">
		<liferay-ui:categorization-filter
			assetType="threads"
			portletURL="<%= portletURL %>"
		/>

		<%@ include file="/html/portlet/message_boards/view_threads.jspf" %>

	</c:when>
	<c:when test='<%= topLink.equals("message-boards-home") %>'>
		
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
		
		<c:if test="<%= category != null && !(String.valueOf(categoryId).equals(rootCategoryId)) %>">
			<div class="category-subscription category-subscription-types">
				<c:if test="<%= enableRSS %>">

					<%
					if (category.getCategoryId() > 0) {
						rssURL.setParameter("mbCategoryId", String.valueOf(category.getCategoryId()));
					}
					else {
						rssURL.setParameter("groupId", String.valueOf(scopeGroupId));
					}
					%>

					<liferay-ui:rss
						delta="<%= rssDelta %>"
						displayStyle="<%= rssDisplayStyle %>"
						feedType="<%= rssFeedType %>"
						resourceURL="<%= rssURL %>"
					/>
				</c:if>
				<c:if test="<%= MBCategoryPermission.contains(permissionChecker, category, ActionKeys.SUBSCRIBE) && (MBUtil.getEmailMessageAddedEnabled(portletPreferences) || MBUtil.getEmailMessageUpdatedEnabled(portletPreferences)) %>">
					<c:choose>
						<c:when test="<%= (categorySubscriptionClassPKs != null) && categorySubscriptionClassPKs.contains(category.getCategoryId()) %>">
							<portlet:actionURL var="unsubscribeURL">
								<portlet:param name="struts_action" value="/message_boards/edit_category" />
								<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.UNSUBSCRIBE %>" />
								<portlet:param name="redirect" value="<%= currentURL %>" />
								<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
							</portlet:actionURL>

							<liferay-ui:icon
								image="unsubscribe"
								label="<%= true %>"
								url="<%= unsubscribeURL %>"
							/>
						</c:when>
						<c:otherwise>
							<portlet:actionURL var="subscribeURL">
								<portlet:param name="struts_action" value="/message_boards/edit_category" />
								<portlet:param name="<%= Constants.CMD %>" value="<%= Constants.SUBSCRIBE %>" />
								<portlet:param name="redirect" value="<%= currentURL %>" />
								<portlet:param name="mbCategoryId" value="<%= String.valueOf(category.getCategoryId()) %>" />
							</portlet:actionURL>

							<liferay-ui:icon
								image="subscribe"
								label="<%= true %>"
								url="<%= subscribeURL %>"
							/>
						</c:otherwise>
					</c:choose>
				</c:if>
			</div>

			<!-- hello -->

			<%
			long parentCategoryId = category.getParentCategoryId();
			String parentCategoryName = LanguageUtil.get(pageContext, "message-boards-home");

			if (!category.isRoot()) {
				MBCategory parentCategory = MBCategoryLocalServiceUtil.getCategory(parentCategoryId);

				parentCategoryId = parentCategory.getCategoryId();
				parentCategoryName = parentCategory.getName();
			}
			%>
			
			<portlet:renderURL var="backURL">
				<portlet:param name="struts_action" value="/message_boards/view" />
				<portlet:param name="mbCategoryId" value="<%= String.valueOf(parentCategoryId) %>" />
			</portlet:renderURL>

			
			<liferay-ui:header
				backLabel="<%= parentCategoryName %>"
				backURL="<%= backURL.toString() %>"
				localizeTitle="<%= false %>"
				title="<%= category.getName() %>"
			/>
		
			
		</c:if>
		
		
		<c:if test="<%= showAddCategoryButton || showAddMessageButton || showPermissionsButton %>">
		
			
 			<%@ include file="/html/portlet/message_boards/category_subscriptions.jspf" %>
 			<div class="topic-actions_CT_MB">
				<div class="buttons_CT_MB">
					<c:if test="<%=showAddCategoryButton%>">
						<portlet:renderURL var="editCategoryURL">
							<portlet:param name="struts_action"
								value="/message_boards/edit_category" />
							<portlet:param name="redirect" value="<%=currentURL%>" />
							<portlet:param name="parentCategoryId"
								value="<%=String.valueOf(categoryId)%>" />
						</portlet:renderURL>

						<div class="reply-icon_CT_MB">
							<a style="text-decoration: none;" href="<%=editCategoryURL%>"
								title="<%=(category == null) ? "Add Category":"Add Subcategory"%>"><i class="icon-comment"></i><%=(category == null) ? "Add Category"
									: "Add Subcategory"%></a>
						</div>
					</c:if>

					<c:if test="<%=showAddMessageButton%>">
						<portlet:renderURL var="editMessageURL">
							<portlet:param name="struts_action"
								value="/message_boards/edit_message" />
							<portlet:param name="redirect" value="<%=currentURL%>" />
							<portlet:param name="mbCategoryId"
								value="<%=String.valueOf(categoryId)%>" />
						</portlet:renderURL>

						<div class="reply-icon_CT_MB">
							<a style="text-decoration: none;" href="<%=editMessageURL%>"
								title="Post New Thread"><i class="icon-comment"></i>Post New Thread</a>
						</div>
					</c:if>

					<c:if test="<%=showPermissionsButton%>">

						<%
							String modelResource = "com.liferay.portlet.messageboards";
											String modelResourceDescription = themeDisplay
													.getScopeGroupName();
											String resourcePrimKey = String
													.valueOf(scopeGroupId);

											if (category != null) {
												modelResource = MBCategory.class.getName();
												modelResourceDescription = category.getName();
												resourcePrimKey = String.valueOf(category
														.getCategoryId());
											}
						%>

						<liferay-security:permissionsURL
							modelResource="<%=modelResource%>"
							modelResourceDescription="<%=HtmlUtil.escape(modelResourceDescription)%>"
							resourcePrimKey="<%=resourcePrimKey%>" var="permissionsURL"
							windowState="<%=LiferayWindowState.POP_UP.toString()%>" />



						<div class="reply-icon_CT_MB">
							<a style="text-decoration: none;" href="<%=permissionsURL%>"
								title="Permissions"><i class="icon-comment"></i>Permissions</a>
						</div>
				
					</c:if>

				</div>
			</div>
 			
			
		</c:if>
		
	
		<c:if test="<%=String.valueOf(categoryId).equals(rootCategoryId) && category!=null%>" >
			<h2 style="font-family:  'Roboto',sans-serif !important;line-height: 1px;font-size: 1.87em!important;font-weight: 100!important;"><a href="#" class="root-category-display_CT_MB"></a><%=category.getName() %></h2>
			<br>
			<b style="font-family:'Roboto',sans-serif!important;font-weight:normal;"><%=category.getDescription() %></b>
		</c:if>

								
		<div class="displayStyle-<%= displayStyle %>">
			<liferay-util:include page='<%= "/html/portlet/message_boards/view_category_" + displayStyle + ".jsp" %>' />
		</div>

		<%
		if (category != null) {
			PortalUtil.setPageSubtitle(category.getName(), request);
			PortalUtil.setPageDescription(category.getDescription(), request);

			MBUtil.addPortletBreadcrumbEntries(category, request, renderResponse);
		}
		%>

	</c:when>
	<c:when test='<%= topLink.equals("my-posts") || topLink.equals("my-subscriptions") || topLink.equals("recent-posts") %>'>

		<%
		if ((topLink.equals("my-posts") || topLink.equals("my-subscriptions")) && themeDisplay.isSignedIn()) {
			groupThreadsUserId = user.getUserId();
		}

		if (groupThreadsUserId > 0) {
			portletURL.setParameter("groupThreadsUserId", String.valueOf(groupThreadsUserId));
		}
		%>

		<c:if test='<%= topLink.equals("recent-posts") && (groupThreadsUserId > 0) %>'>
			<div class="alert alert-info">
				<liferay-ui:message key="filter-by-user" />: <%= HtmlUtil.escape(PortalUtil.getUserName(groupThreadsUserId, StringPool.BLANK)) %>
			</div>
		</c:if>

		<c:if test='<%= topLink.equals("my-subscriptions") %>'>
			<liferay-ui:search-container
				curParam="cur1"
				deltaConfigurable="<%= false %>"
				emptyResultsMessage="you-are-not-subscribed-to-any-categories"
				headerNames="category,categories,threads,posts"
				iteratorURL="<%= portletURL %>"
				total="<%= MBCategoryServiceUtil.getSubscribedCategoriesCount(scopeGroupId, user.getUserId()) %>"
			>
				<liferay-ui:search-container-results
					results="<%= MBCategoryServiceUtil.getSubscribedCategories(scopeGroupId, user.getUserId(), searchContainer.getStart(), searchContainer.getEnd()) %>"
				/>

				<liferay-ui:search-container-row
					className="com.liferay.portlet.messageboards.model.MBCategory"
					escapedModel="<%= true %>"
					keyProperty="categoryId"
					modelVar="curCategory"
				>
					<liferay-ui:search-container-row-parameter name="categorySubscriptionClassPKs" value="<%= categorySubscriptionClassPKs %>" />

					<liferay-portlet:renderURL varImpl="rowURL">
						<portlet:param name="struts_action" value="/message_boards/view" />
						<portlet:param name="mbCategoryId" value="<%= String.valueOf(curCategory.getCategoryId()) %>" />
					</liferay-portlet:renderURL>

					<%@ include file="/html/portlet/message_boards/subscribed_category_columns.jspf" %>
				</liferay-ui:search-container-row>

				<liferay-ui:search-iterator type="more" />
			</liferay-ui:search-container>
		</c:if>

		<%@ include file="/html/portlet/message_boards/view_threads.jspf" %>

		<c:if test='<%= enableRSS && topLink.equals("recent-posts") %>'>

			<%
			rssURL.setParameter("groupId", String.valueOf(scopeGroupId));

			if (groupThreadsUserId > 0) {
				rssURL.setParameter("userId", String.valueOf(groupThreadsUserId));
			}

			rssURL.setParameter("mbCategoryId", StringPool.BLANK);
			%>

			<br />

			<liferay-ui:rss
				delta="<%= rssDelta %>"
				displayStyle="<%= rssDisplayStyle %>"
				feedType="<%= rssFeedType %>"
				message="subscribe-to-recent-posts"
				resourceURL="<%= rssURL %>"
			/>
		</c:if>

		<%
		PortalUtil.setPageSubtitle(LanguageUtil.get(pageContext, StringUtil.replace(topLink, StringPool.UNDERLINE, StringPool.DASH)), request);
		PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, TextFormatter.format(topLink, TextFormatter.O)), portletURL.toString());
		%>

	</c:when>
	<c:when test='<%= topLink.equals("statistics") %>'>
		<liferay-ui:panel-container cssClass="statistics-panel" extended="<%= false %>" id="messageBoardsStatisticsPanelContainer" persistState="<%= true %>">
			<liferay-ui:panel collapsible="<%= true %>" cssClass="statistics-panel-content" extended="<%= true %>" id="messageBoardsGeneralStatisticsPanel" persistState="<%= true %>" title="general">
				<dl>
					<dt>
						<liferay-ui:message key="num-of-categories" />:
					</dt>
					<dd>
						<%= numberFormat.format(categoryDisplay.getAllCategoriesCount()) %>
					</dd>
					<dt>
						<liferay-ui:message key="num-of-posts" />:
					</dt>
					<dd>
						<%= numberFormat.format(MBStatsUserLocalServiceUtil.getMessageCountByGroupId(scopeGroupId)) %>
					</dd>
					<dt>
						<liferay-ui:message key="num-of-participants" />:
					</dt>
					<dd>
						<%= numberFormat.format(MBStatsUserLocalServiceUtil.getStatsUsersByGroupIdCount(scopeGroupId)) %>
					</dd>
				</dl>
			</liferay-ui:panel>

			<liferay-ui:panel collapsible="<%= true %>" cssClass="statistics-panel-content" extended="<%= true %>" id="messageBoardsTopPostersPanel" persistState="<%= true %>" title="top-posters">
				<liferay-ui:search-container
					emptyResultsMessage="there-are-no-top-posters"
					iteratorURL="<%= portletURL %>"
					total="<%= MBStatsUserLocalServiceUtil.getStatsUsersByGroupIdCount(scopeGroupId) %>"
				>
					<liferay-ui:search-container-results
						results="<%= MBStatsUserLocalServiceUtil.getStatsUsersByGroupId(scopeGroupId, searchContainer.getStart(), searchContainer.getEnd()) %>"
					/>

					<liferay-ui:search-container-row
						className="com.liferay.portlet.messageboards.model.MBStatsUser"
						keyProperty="statsUserId"
						modelVar="statsUser"
					>
						<liferay-ui:search-container-column-jsp
							path="/html/portlet/message_boards/top_posters_user_display.jsp"
						/>
					</liferay-ui:search-container-row>

					<liferay-ui:search-iterator />
				</liferay-ui:search-container>
			</liferay-ui:panel>
		</liferay-ui:panel-container>

		<%
		PortalUtil.setPageSubtitle(LanguageUtil.get(pageContext, StringUtil.replace(topLink, StringPool.UNDERLINE, StringPool.DASH)), request);
		PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, TextFormatter.format(topLink, TextFormatter.O)), portletURL.toString());
		%>

	</c:when>
	<c:when test='<%= topLink.equals("banned-users") %>'>
		<liferay-ui:search-container
			emptyResultsMessage="there-are-no-banned-users"
			headerNames="banned-user,banned-by,ban-date"
			iteratorURL="<%= portletURL %>"
			total="<%= MBBanLocalServiceUtil.getBansCount(scopeGroupId) %>"
		>
			<liferay-ui:search-container-results
				results="<%= MBBanLocalServiceUtil.getBans(scopeGroupId, searchContainer.getStart(), searchContainer.getEnd()) %>"
			/>

			<liferay-ui:search-container-row
				className="com.liferay.portlet.messageboards.model.MBBan"
				keyProperty="banId"
				modelVar="ban"
			>

				<%
				String bannedUserDisplayURL = StringPool.BLANK;

				try {
					User bannedUser = UserLocalServiceUtil.getUser(ban.getBanUserId());

					bannedUserDisplayURL = bannedUser.getDisplayURL(themeDisplay);
				}
				catch (NoSuchUserException nsue) {
				}
				%>

				<liferay-ui:search-container-column-text
					href="<%= bannedUserDisplayURL %>"
					name="banned-user"
					
					buffer="buffer"
				>
				<% 
				buffer.append("<div class=\"forabg_CT_MB\" style=\"margin-bottom: 0px\">" +
			            "<div class=\"inner_CT_MB\">" +
			            "<ul class=\"topiclist_CT_MB forums_CT_MB kd-forum-class1 kd-forum-body_CT_MB collapse_CT_MB in_CT_MB\"" +
			            "    id=\"kd-forum1\">" +
			            "    <li class=\"row_CT_MB\">" +
			            "        <dl class=\"icon_CT_MB\"" +
			            "            style=\"background-image: url("+"url"+"); background-repeat: no-repeat; margin-bottom: 0px;\">" +
			            "            <dt title=\"No unread posts\" style=\"font-weight: 500;\">" +
			            "                <!-- <a class=\"feed-icon-forum\" title=\"Feed - Password protected\" href=\"http://phpbb3responsive.com/demo/feed.php?f=5\"><img src=\"./styles/Charon%20-%20Main/theme/images/feed.gif\" alt=\"Feed - Password protected\" /></a> -->" +
			            "                <a href=\""+bannedUserDisplayURL.toString()+"\" class=\"forumtitle_CT_MB\">" +
			            		HtmlUtil.escape(PortalUtil.getUserName(ban.getBanUserId(), StringPool.BLANK)) +"<br>"+
			            "            <div class=\"line-separator_CT_MB\"></div>" +
			            "            <div class=\"short-description_CT_MB\" style=\"\">" +
			            "            "+
			            /* flagStrObj+ */
					    			 /* ""+dateFormatObj.format(ban.getCreateDate())+"&nbsp;Ban Date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+dateFormatObj.format(MBUtil.getUnbanDate(ban, PropsValues.MESSAGE_BOARDS_EXPIRE_BAN_INTERVAL))+"&nbsp;Unban Date" + */
			            "            </div>" +
			            "            </dt>           " +
			            "        </dl>" +
			            "    </li>" +
			            "" +
			            "</ul>" +
			            "</div>" +
			            "</div>");	
    			%>
				
				</liferay-ui:search-container-column-text>

				<%
				String bannedByUserDisplayURL = StringPool.BLANK;

				try {
					User bannedByUser = UserLocalServiceUtil.getUser(ban.getUserId());

					bannedByUserDisplayURL = bannedByUser.getDisplayURL(themeDisplay);
				}
				catch (NoSuchUserException nsue) {
				}
				%>

				<liferay-ui:search-container-column-text
					href="<%= bannedByUserDisplayURL %>"
					name="banned-by"
					buffer="buffer"
				>
				<% 
				buffer.append("<div class=\"forabg_CT_MB\" style=\"margin-bottom: 0px\">" +
			            "<div class=\"inner_CT_MB\">" +
			            "<ul class=\"topiclist_CT_MB forums_CT_MB kd-forum-class1 kd-forum-body_CT_MB collapse_CT_MB in_CT_MB\"" +
			            "    id=\"kd-forum1\">" +
			            "    <li class=\"row_CT_MB\">" +
			            "        <dl class=\"icon_CT_MB\"" +
			            "            style=\"background-image: url("+"url"+"); background-repeat: no-repeat; margin-bottom: 0px;\">" +
			            "            <dt title=\"No unread posts\" style=\"font-weight: 500;padding: 0px;\">" +
			            "                <!-- <a class=\"feed-icon-forum\" title=\"Feed - Password protected\" href=\"http://phpbb3responsive.com/demo/feed.php?f=5\"><img src=\"./styles/Charon%20-%20Main/theme/images/feed.gif\" alt=\"Feed - Password protected\" /></a> -->" +
			            "                <a href=\""+bannedUserDisplayURL.toString()+"\" class=\"forumtitle_CT_MB\">" +
			            		HtmlUtil.escape(PortalUtil.getUserName(ban.getUserId(), StringPool.BLANK)) +"<br>"+
			            "            </dt>           " +
			            "        </dl>" +
			            "    </li>" +
			            "" +
			            "</ul>" +
			            "</div>" +
			            "</div>");
				%>
				</liferay-ui:search-container-column-text>

				<liferay-ui:search-container-column-date
					name="ban-date"
					value="<%= ban.getCreateDate() %>"
				>
				</liferay-ui:search-container-column-date>

				<c:if test="<%= PropsValues.MESSAGE_BOARDS_EXPIRE_BAN_INTERVAL > 0 %>">
					<liferay-ui:search-container-column-date
						name="unban-date"
						value="<%= MBUtil.getUnbanDate(ban, PropsValues.MESSAGE_BOARDS_EXPIRE_BAN_INTERVAL) %>"
					/>
				</c:if>

				<liferay-ui:search-container-column-jsp
					align="right"
					path="/html/portlet/message_boards/ban_user_action.jsp"
				/>
			</liferay-ui:search-container-row>

			<liferay-ui:search-iterator />
		</liferay-ui:search-container>

		<%
		PortalUtil.setPageSubtitle(LanguageUtil.get(pageContext, StringUtil.replace(topLink, StringPool.UNDERLINE, StringPool.DASH)), request);
		PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, TextFormatter.format(topLink, TextFormatter.O)), portletURL.toString());
		%>

	</c:when>
</c:choose>

<%!
private static Log _log = LogFactoryUtil.getLog("portal-web.docroot.html.portlet.message_boards.view_jsp");
%>