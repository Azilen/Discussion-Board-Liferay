package com.message.board.override.statistics;

import java.util.ArrayList;
import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import com.liferay.message.boards.kernel.model.MBCategoryConstants;
import com.liferay.message.boards.kernel.service.MBMessageLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBStatsUserLocalServiceUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.message.board.override.constant.MBPortletNameKeys;
import com.message.board.util.MessageBoardUtil;

@Component(
		immediate = true,
		property = {
				"javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS,
				"mvc.command.name=/message_boards/view_statistics",
				"service.ranking:Integer=100"
		},
		service=MVCRenderCommand.class
)
public class MBCustomStatistics implements MVCRenderCommand{
	
	private static final Log _log = LogFactoryUtil.getLog(MBCustomStatistics.class);
	
	/*
	 * This method s used to get statistics of selected category
	 */
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		int messageCount = 0;
		List<Long> allChildCategoryList = new ArrayList<Long>();
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), MBPortletNameKeys.MESSAGE_BOARDS);
		long preferenceCategoryID = Long.parseLong(preferences.getValue(MBPortletNameKeys.CATEGORY_ID, "-1"));
		_log.debug("Preference Category ID :=>"+preferenceCategoryID);
		renderRequest.setAttribute("categoryID",preferenceCategoryID);
		_log.debug("Message Count :=>"+messageCount);
		//if preferenceCategory is not set then we take default categoryID 0
		if(preferenceCategoryID == -1){
			allChildCategoryList	=	MessageBoardUtil.getAllChildCataegory(allChildCategoryList, themeDisplay.getScopeGroupId(), MBCategoryConstants.DEFAULT_PARENT_CATEGORY_ID);	
			allChildCategoryList.add(MBCategoryConstants.DEFAULT_PARENT_CATEGORY_ID);
		}else{
			allChildCategoryList	=	MessageBoardUtil.getAllChildCataegory(allChildCategoryList, themeDisplay.getScopeGroupId(), preferenceCategoryID);
			//adding preference categoryID to list because we also want to get all thread of this categoryID
			allChildCategoryList.add(preferenceCategoryID);
		}
		
		for(Long categoryId : allChildCategoryList){
			_log.debug("category: "+categoryId);
			_log.debug("category thread: "+MBMessageLocalServiceUtil.getCategoryMessagesCount(themeDisplay.getScopeGroupId(), categoryId, WorkflowConstants.STATUS_APPROVED));
			_log.debug("messagecount: "+messageCount);
			messageCount = messageCount + MBMessageLocalServiceUtil.getCategoryMessagesCount(themeDisplay.getScopeGroupId(), categoryId, WorkflowConstants.STATUS_APPROVED);
			_log.debug("Category Id :=>"+categoryId +" : "+messageCount);
		}
		_log.debug("allChildCategoryList size :=>"+allChildCategoryList.size());
		renderRequest.setAttribute("threadUserList", MessageBoardUtil.getThreadUser(themeDisplay.getScopeGroupId(), allChildCategoryList));
		//subtract 1 value from  allChildCategoryList size because we only display count of all child category of selected categry
		renderRequest.setAttribute("totalCategory", (allChildCategoryList.size() - 1));
		renderRequest.setAttribute("messageCount", messageCount);
		return getMvcRenderCommand().render(renderRequest, renderResponse);
	}
	
	public MVCRenderCommand getMvcRenderCommand(){
		return mvcRenderCommand;
	}

	@Reference(target = "(&(mvc.command.name=/message_boards/view_statistics)(javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS + ")(component.name=com.liferay.message.boards.web.internal.portlet.action.ViewStatisticsMVCRenderCommand))" )
	public void setMvcRenderCommand( MVCRenderCommand mvcRenderCommand ){
		this.mvcRenderCommand = mvcRenderCommand;
	}

	protected MVCRenderCommand mvcRenderCommand;

	
}
