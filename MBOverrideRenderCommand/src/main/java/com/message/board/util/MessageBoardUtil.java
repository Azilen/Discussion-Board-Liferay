package com.message.board.util;

import java.util.ArrayList;
import java.util.List;

import com.liferay.message.boards.kernel.model.MBCategory;
import com.liferay.message.boards.kernel.model.MBMessage;
import com.liferay.message.boards.kernel.model.MBStatsUser;
import com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBMessageLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBStatsUserLocalServiceUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.workflow.WorkflowConstants;

public class MessageBoardUtil {
	
	private static final Log _log = LogFactoryUtil.getLog(MessageBoardUtil.class);

	
	//this method return all child category of give parent category
	public static List<Long> getAllChildCataegory(List<Long> allChildCategoryList,long groupID,long parentCategoryID){
		List<MBCategory> childCatgoryList = MBCategoryLocalServiceUtil.getCategories(groupID, parentCategoryID, -1, -1);
		for(MBCategory childCategory : childCatgoryList){
			allChildCategoryList.add(childCategory.getCategoryId());
			getAllChildCataegory(allChildCategoryList,groupID,childCategory.getCategoryId());
		}
		MBMessageLocalServiceUtil.getCategoryMessages(groupID, parentCategoryID, WorkflowConstants.STATUS_APPROVED, -1, -1);
		return allChildCategoryList;
	}
	
	//this method is list of user who has post any thread in selected category
	public static List<MBStatsUser> getThreadUser(long groupID,List<Long> allChildCategoryList){
		List<MBStatsUser> listOfMBStatsUser = new ArrayList<MBStatsUser>();
		for(Long categoryID : allChildCategoryList){
			_log.debug("categoryID :=>"+categoryID);
			List<MBMessage> listOfMessage = MBMessageLocalServiceUtil.getCategoryMessages(groupID, categoryID, WorkflowConstants.STATUS_APPROVED, -1, -1);
			for(MBMessage message : listOfMessage){
				_log.debug("Message :=>"+message.getSubject()+ " : "+message.getUserId() + " : "+message.getUserName());
				MBStatsUser mbStatsUser=MBStatsUserLocalServiceUtil.getStatsUser(groupID, message.getUserId());
				if(!listOfMBStatsUser.contains(mbStatsUser)){
					listOfMBStatsUser.add(mbStatsUser);
				}
			}
		}
		_log.debug("List of mb User :=>"+listOfMBStatsUser);
		return listOfMBStatsUser;
	}
}
