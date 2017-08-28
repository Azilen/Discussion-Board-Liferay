package com.message.board.override.search;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.message.board.override.constant.MBPortletNameKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
		immediate = true,
		property = {
				"javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS,
				"mvc.command.name=/message_boards/search",
				"service.ranking:Integer=100"
		},
		service =MVCRenderCommand.class
		)
public class MBCustomSearch implements MVCRenderCommand{
	
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		renderRequest.setAttribute("categoryId",ParamUtil.getString(renderRequest, "searchCategoryId") );
		return getMvcRenderCommand().render(renderRequest, renderResponse);
	}
	
	public MVCRenderCommand getMvcRenderCommand(){
		return mvcRenderCommand;
	}

	@Reference(target = "(&(mvc.command.name=/message_boards/search)(javax.portlet.name=" + MBPortletNameKeys.MESSAGE_BOARDS + ")(component.name=com.liferay.message.boards.web.internal.portlet.action.SearchMVCRenderCommand))" )
	public void setMvcRenderCommand( MVCRenderCommand mvcRenderCommand ){
		this.mvcRenderCommand = mvcRenderCommand;
	}

	protected MVCRenderCommand mvcRenderCommand;

	
}
