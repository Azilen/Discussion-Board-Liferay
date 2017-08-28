package com.message.board.configuration;

import java.util.Map;
import com.message.board.configuration.MBConfig;
import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletConfig;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.ConfigurationPolicy;
import org.osgi.service.component.annotations.Modified;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.ConfigurationAction;
import com.liferay.portal.kernel.portlet.DefaultConfigurationAction;
import com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.message.board.util.Constant;
import aQute.bnd.annotation.metatype.Configurable;
import com.liferay.portal.kernel.theme.ThemeDisplay;

@Component(
		configurationPid = Constant.CONFIGURATION_PID,
		configurationPolicy = ConfigurationPolicy.OPTIONAL,
		immediate = true,
		property = {"javax.portlet.name="+Constant.MESSAGE_BOARDS},
		service = ConfigurationAction.class
		)
public class MBConfigAction extends DefaultConfigurationAction  {
	
	private volatile MBConfig _categoryConfig;
	
	private static final Log _log = LogFactoryUtil.getLog(MBConfigAction.class);
	
	@Override
	public void processAction(PortletConfig portletConfig, ActionRequest actionRequest,
							  ActionResponse actionResponse) throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		String category=ParamUtil.getString(actionRequest, Constant.CATEGORY_NAME);
		if(!category.isEmpty()){
			String[] categoryName = ParamUtil.getString(actionRequest, Constant.CATEGORY_NAME).split(":");
			_log.debug("Category name is:"+categoryName+" For page:"+themeDisplay.getLayout().getName());
			javax.portlet.PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), Constant.MESSAGE_BOARDS);
			preferences.setValue(MBConfig.FIELD_CATEGORY, categoryName[0]);
			preferences.setValue(Constant.CATEGORY_ID, categoryName[1]);
			preferences.store();
			_log.debug("Category name is:"+categoryName+" For page:"+themeDisplay.getLayout().getName());
		}
		
		super.processAction(portletConfig, actionRequest, actionResponse);
	}

	@Override
	public void include(
			PortletConfig portletConfig, HttpServletRequest httpServletRequest,
			HttpServletResponse httpServletResponse) throws Exception {
		httpServletRequest.setAttribute(MBConfig.class.getName(),_categoryConfig);
		super.include(portletConfig, httpServletRequest, httpServletResponse);
	}

	@Activate
	@Modified
	protected void activate(Map<Object, Object> properties) {
		_categoryConfig = Configurable.createConfigurable(MBConfig.class, properties);
	}
}
