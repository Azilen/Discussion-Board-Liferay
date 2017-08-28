<%@page import="com.liferay.taglib.servlet.JspWriterHttpServletResponse"%>
<%@page import="com.liferay.message.boards.web.constants.MBPortletKeys"%>
<%@page import="com.google.gson.JsonElement"%>
<%@page import="com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil"%>
<%@page import="com.liferay.portal.kernel.util.WebKeys"%>
<%@page import="java.util.ArrayList"%>
<%@page import="javax.portlet.PortletPreferences"%>
<%@ page import="com.liferay.portal.kernel.util.Constants"%>
<%@page import="com.liferay.message.boards.kernel.model.MBCategory"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashSet"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil"%>
<%@page import="com.liferay.message.boards.kernel.model.MBCategoryConstants"%>
<%@page import="com.liferay.message.boards.kernel.service.MBDiscussionLocalServiceUtil"%>
<%@page import="com.azilen.message.boards.category.tree.CreateCategoryTree"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet"%>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@page import="com.liferay.portal.kernel.util.StringPool"%>
<%@page import="com.liferay.portal.kernel.util.Validator"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui"%>
<%@include file="/css/custom_css.jsp" %>
<liferay-theme:defineObjects />
<liferay-portlet:actionURL portletConfiguration="<%=true %>"
	var="configActionURL" />
<%
  PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), MBPortletKeys.MESSAGE_BOARDS);
  /*selectedCategoryId is the category selected in preference*/
  String preferenceDefaultValue="-1";
	String selectedCategoryId=preferences.getValue("categoryID", preferenceDefaultValue);
	String selectedCategoryName=preferences.getValue("categoryName", preferenceDefaultValue);
	request.setAttribute("selectedCategoryId", selectedCategoryId);
	JsonElement categoryTree=CreateCategoryTree.prepareCategoryTree(request);
 %>

 <%if(selectedCategoryName != preferenceDefaultValue){ %>
Your selected preference category:-<%=selectedCategoryName %>
<%} %> 
 
 <div id="myTreeView"></div>
<script type="text/javascript">
YUI().use(
  'aui-tree-view',
  
 function(Y) {
   var tree= new Y.TreeView(

    		{
    			boundingBox: '#myTreeView',
				children:  <%=categoryTree%>
					}
    ).render();
   
   tree.on('click', function(event){
	                getCheckedElement(tree);
	              });
   
   tree.after("lastSelectedChange", function(event) {
	                getCheckedElement(tree);
	                });
  }
);

Liferay.provide(
		            window,
		            'getCheckedElement',
		            function(product_configurator_tree) {
		                 var nodeList = new Array();
		                nodeList = product_configurator_tree.getChildren(true);
		               var attrNodeObj = "";
		                for( var i = 0 ; i < nodeList.length ; i++){
		                	if(nodeList[i].isChecked()){
		                		$(".categoryName").val(nodeList[i].get("label")+":"+nodeList[i].get("id"));
		                		nodeList[i].set("checked",true);
		                	}
		               } 
		            });


</script>
<div id='categoryMainDiv'>
  <aui:form  action="<%=configActionURL%>" method="post" name="fm" id="categoryForm">
 	<aui:input name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.UPDATE %>" />
  <input name="<portlet:namespace/>categoryName" type="hidden" value="" id="categoryName" class="categoryName"/> 
     	
   		<div>
   		<button type="submit" class='btn  submitButton'>Save</button>
   		</div>
  </aui:form>
 </div>  