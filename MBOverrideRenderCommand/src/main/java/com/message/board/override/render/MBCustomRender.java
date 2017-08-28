package com.message.board.override.render;

import com.liferay.message.boards.kernel.model.MBCategory;
import com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.message.board.override.constant.MBPortletNameKeys;
import java.util.ArrayList;
import java.util.List;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import javax.portlet.PortletException;
import javax.portlet.PortletPreferences;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
@Component(
		immediate = true,
		property = {
				"javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS,
				"mvc.command.name=/message_boards/view_category",
				"service.ranking:Integer=100"
		},
		service = MVCRenderCommand.class
		)
public class MBCustomRender implements MVCRenderCommand {

	private static final Log _log = LogFactoryUtil.getLog(MBCustomRender.class);

	/* 
	 * Override render method for render command "/message_boards/view_category" 
	 */
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		boolean isExist		=	true;
		MBCategory category	=	null;
		long categoryId = ParamUtil.getLong(renderRequest, MBPortletNameKeys.MB_CATEGORYID);
		_log.debug("Entry:render method");
		try {
			if(categoryId != 0){
				category=MBCategoryLocalServiceUtil.getCategory(categoryId);
			}
			
			ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
			String portletName= themeDisplay.getPortletDisplay().getPortletName();
			PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), MBPortletNameKeys.MESSAGE_BOARDS);

			//Category stored in preference 
			long preferenceCategoryID	=	Long.parseLong(preferences.getValue(MBPortletNameKeys.CATEGORY_ID, "-1"));

			//Category that will be displayed in message board page based on condition.
			MBCategory selectedCategory=null;
			if(preferenceCategoryID != -1){
				 selectedCategory = MBCategoryLocalServiceUtil.getCategory(preferenceCategoryID);
			}
			if(category != null && selectedCategory!=null){
				List<Long> categoryList = getParentsAndChildren(selectedCategory.getCategoryId(),themeDisplay);
				isExist=checkIdExist(categoryId,categoryList);
			}
			
			if((isExist) && (portletName.equalsIgnoreCase(MBPortletNameKeys.MESSAGE_BOARDS) && (category != null))){
				if(selectedCategory != null){

					if(category.getName().equalsIgnoreCase(selectedCategory.getName())){
						renderRequest.setAttribute(MBPortletNameKeys.SELECTED_CATEGORY, selectedCategory);
					}
					else if(!category.getName().equalsIgnoreCase(selectedCategory.getName())){
						renderRequest.setAttribute(MBPortletNameKeys.SELECTED_CATEGORY, category);
						
					}
					else{
						renderRequest.setAttribute(MBPortletNameKeys.SELECTED_CATEGORY, selectedCategory);
					}
				}
				else{
					renderRequest.setAttribute(MBPortletNameKeys.SELECTED_CATEGORY, category);
				}
				renderRequest.setAttribute(MBPortletNameKeys.ERROR_MESSAGE, MBPortletNameKeys.NO_MESSAGE);
			}
			else{
				renderRequest.setAttribute(MBPortletNameKeys.ERROR_MESSAGE, MBPortletNameKeys.SHOW_MESSAGE);
			}
		} catch (Exception e) {
			_log.error("Exception while executing render method :",e);
		}
		return getMvcRenderCommand().render(renderRequest, renderResponse);
	}


	/**
	 * @param preferenceCatId
	 * @param themeDisplay
	 * @return list containing parent and child categories of preference category
	 * @throws PortalException
	 */
	private List<Long> getParentsAndChildren(long preferenceCatId,ThemeDisplay themeDisplay) throws PortalException {
		List<Long> parentsList=new ArrayList<>();
		long groupId=themeDisplay.getScopeGroupId();
		long categoryId=preferenceCatId;
		do{
			parentsList.add(categoryId);
			categoryId=MBCategoryLocalServiceUtil.getCategory(categoryId).getParentCategoryId();
		}while(categoryId != 0);
		parentsList.addAll(MBCategoryLocalServiceUtil.getSubcategoryIds(new ArrayList<>(), groupId, preferenceCatId));
		return parentsList;

	}
	
	/**
	 * @param categoryId
	 * @param catIds
	 * @return boolean variable if categoryId exist in catIds list
	 * Check if category id requested in URL exist in list containing parent and child categories of selected preference category.
	 */
	public boolean checkIdExist(long categoryId,List<Long> catIds){
		boolean isExist=false;
		for(long cat:catIds){
			if(categoryId==cat){
				isExist=true;
				break;
			}
		}
		return isExist;
	}


	public MVCRenderCommand getMvcRenderCommand(){
		return mvcRenderCommand;
	}

	@Reference(target = "(&(mvc.command.name=/message_boards/view_category)(javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS + ")(component.name=com.liferay.message.boards.web.internal.portlet.action.ViewMVCRenderCommand))" )
	public void setMvcRenderCommand( MVCRenderCommand mvcRenderCommand ){
		this.mvcRenderCommand = mvcRenderCommand;
	}

	protected MVCRenderCommand mvcRenderCommand;
}
