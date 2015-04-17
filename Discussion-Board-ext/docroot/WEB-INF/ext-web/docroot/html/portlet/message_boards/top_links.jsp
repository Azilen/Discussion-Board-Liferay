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

<%@ include file="/html/portlet/message_boards/init.jsp" %>

<%
String topLink = ParamUtil.getString(request, "topLink", "message-boards-home");

MBCategory category = (MBCategory)request.getAttribute(WebKeys.MESSAGE_BOARDS_CATEGORY);

long categoryId = MBUtil.getCategoryId(request, category);

	
boolean viewCategory = GetterUtil.getBoolean((String)request.getAttribute("view.jsp-viewCategory"));

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/message_boards/view");
%>



<script type="text/javascript">
    // <![CDATA[
    var jump_page = 'Enter the page number you wish to go to:';
    var on_page = '';
    var per_page = '';
    var base_url = '';
    var style_cookie = 'phpBBstyle';
    var style_cookie_settings = '; path=/; domain=.phpbb3responsive.com';
    var onload_functions = new Array();
    var onunload_functions = new Array();



    /**
     * Find a member
     */
    function find_username(url)
    {
        popup(url, 760, 570, '_usersearch');
        return false;
    }

    /**
     * New function for handling multiple calls to window.onload and window.unload by pentapenguin
     */
    window.onload = function()
    {
        for (var i = 0; i < onload_functions.length; i++)
        {
            eval(onload_functions[i]);
        }
    };

    window.onunload = function()
    {
        for (var i = 0; i < onunload_functions.length; i++)
        {
            eval(onunload_functions[i]);
        }
    };

    // ]]>
</script>


 
 		
 
 
 
<div id="wrapheader" class="navbar_MB navbar_MB-fixed-top">
    <!-- #page-header end -->

    <div id="page-header">

        <div class="inner-header_MB">
            <div class="logodiv_MB pull-left_MB"><h1><a href="#">Discussion Boards</a></h1></div>	
            <a class="btn-navbar_MB" >
                <span class="btn-bar_MB"></span>
                <span class="btn-bar_MB"></span>
                <span class="btn-bar_MB"></span>
                <span class="btn-bar_MB"></span>
            </a>
            <!-- The button for collapse menu end -->
        </div>

        <div class="nav-collapse_MB collapse_MB pull-right_MB" id="btn-navbar">
            <!-- Collapse div start -->
            <div class="navbar_MB-holder">
                <ul class="navbar_MB-links" style="margin: 0">
                
                	<%
					String label = "message-boards-home";
			
					portletURL.setParameter("topLink", label);
					portletURL.setParameter("tag", StringPool.BLANK);
					%>
					
                    <li id="home" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="Message Boards Home"> <span class="holdericon_MB"><i
                            class="icon-home"></i></span> <span class="header-label_MB">Home</span></a></li>

					<%
					label = "recent-posts";
			
					portletURL.setParameter("topLink", label);
					%>
                    <li id="recent-posts" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="Recent Posts"> <span class="holdericon_MB"><i
                            class="icon-comment"></i></span> <span class="header-label_MB">Recent Posts</span></a></li>


					<c:if test="<%= themeDisplay.isSignedIn() && !portletName.equals(PortletKeys.MESSAGE_BOARDS_ADMIN) %>">

						<%
						label = "my-posts";
			
						portletURL.setParameter("topLink", label);
						%>
			
						<li id="my-posts" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="My Posts"> <span class="holdericon_MB"><i
                            class="icon-user"></i></span> <span class="header-label_MB">My Posts</span></a></li>
			
						<c:if test="<%= MBUtil.getEmailMessageAddedEnabled(portletPreferences) || MBUtil.getEmailMessageUpdatedEnabled(portletPreferences) %>">
			
							<%
							label = "my-subscriptions";
			
							portletURL.setParameter("topLink", label);
							%>
			
							<li id="my-subscriptions" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="My Subcriptions"> <span class="holdericon_MB"><i
                            class="icon-foursquare"></i></span> <span class="header-label_MB">My Subscriptions</span></a></li>

						</c:if>
					</c:if>

                    <%
					label = "statistics";
			
					portletURL.setParameter("topLink", label);
					%>
					
                    <li id="statistics" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="Statistics"> <span class="holdericon_MB"><i
                            class="icon-retweet"></i></span> <span class="header-label_MB">statistics</span></a></li>
                   
                   	<c:if test="<%= MBPermission.contains(permissionChecker, scopeGroupId, ActionKeys.BAN_USER) %>">

						<%
						label = "banned-users";
			
						portletURL.setParameter("topLink", label);
						%>
			
						<li id="banned-users" class="<%= topLink.equals(label) ? "navbar_MB-ActiveTab" : StringPool.BLANK %>"><a
                            style="text-decoration: none;" href="<%= portletURL.toString() %>"
                            title="Banned Users"> <span class="holdericon_MB"><i
                            class="icon-minus"></i></span> <span class="header-label_MB">Banned Users</span></a></li>
					</c:if>
                   	         
                    
                
                </ul>
            </div>
            <!-- navbar-holder end-->
        </div>
        <!-- collapse div end-->
    </div>
</div>



<script type="text/javascript" src="<%= PortalUtil.getStaticResourceURL(request, themeDisplay.getPortalURL() + "/html/css/integrate/js/jquery.js")  %>"></script>
<script type="text/javascript" src="<%= PortalUtil.getStaticResourceURL(request, themeDisplay.getPortalURL() + "/html/css/integrate/js/bootstrap.js")  %>"></script>
<script type="text/javascript" src="<%= PortalUtil.getStaticResourceURL(request, themeDisplay.getPortalURL() + "/html/css/integrate/js/custom.js")  %>"></script>






<c:if test="<%=layout.isTypeControlPanel()%>">
	<div id="breadcrumb">
		<liferay-ui:breadcrumb showCurrentGroup="<%= false %>" showCurrentPortlet="<%= false %>" showGuestGroup="<%= false %>" showLayout="<%= false %>" showPortletBreadcrumb="<%= true %>" />
	</div>
</c:if>





<aui:nav-bar>

 <c:if test="<%= showSearch %>">
		<liferay-portlet:renderURL varImpl="searchURL">
			<portlet:param name="struts_action" value="/message_boards/search" />
		</liferay-portlet:renderURL>

		<aui:nav-bar-search cssClass="pull-right" id="_19_MB">
			<div class="form-search">
				<aui:form action="<%= searchURL %>" method="get" name="searchFm">
					<liferay-portlet:renderURLParams varImpl="searchURL" />
					<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
					<aui:input name="breadcrumbsCategoryId" type="hidden" value="<%= categoryId %>" />
					<aui:input name="searchCategoryId" type="hidden" value="<%= categoryId %>" />

					<liferay-ui:input-search id="keywords1" />
				</aui:form>
			</div>
		</aui:nav-bar-search>

		<c:if test="<%= windowState.equals(WindowState.MAXIMIZED) && !themeDisplay.isFacebook() %>">
			<aui:script>
				Liferay.Util.focusFormField(document.getElementById('<portlet:namespace />keywords1'));
			</aui:script>
		</c:if>
	</c:if>
</aui:nav-bar>

