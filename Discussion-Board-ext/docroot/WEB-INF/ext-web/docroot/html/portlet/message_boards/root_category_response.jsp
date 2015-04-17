<%@page import="com.liferay.portal.theme.PortletDisplay"%>
<%@ include file="/html/portlet/message_boards/init.jsp" %>
 
 <h1>Root configured Succesfully.</h1>

<%
String windowKey=ParamUtil.getString(request, "windowKey");
windowKey=windowKey.substring(windowKey.indexOf("_"), windowKey.length());
String categoryId=ParamUtil.getString(request, "categoryId");
String categoryName=ParamUtil.getString(request, "categoryName");
if(!categoryId.equals("-1"))
{		
	
	
	ThemeDisplay themeDisplayObj2= (ThemeDisplay) request.getAttribute(WebKeys.THEME_DISPLAY);
	PortletDisplay portletDisplayObj= themeDisplayObj2.getPortletDisplay();
	String portletId= portletDisplayObj.getId();
	PortletPreferences preferences = PortletPreferencesFactoryUtil.getPortletSetup(request, portletId);
	preferences.setValue(windowKey, ""+categoryId);
	preferences.store();
	String testValue=GetterUtil.getString(preferences.getValue(windowKey, "0"));
	
	if(categoryId.equals("0"))
	{
		session.setAttribute("MBCategoryNameParam", "Message Boards Home");
		session.setAttribute("MBCategoryIdParam","-1" );
	}
	else
	{
		session.setAttribute("MBCategoryNameParam", categoryName);
		session.setAttribute("MBCategoryIdParam",""+categoryId );
	}
	
	

}
%>
