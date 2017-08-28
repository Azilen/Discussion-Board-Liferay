package com.azilen.message.boards.category.tree;

import com.azilen.message.boards.constants.CustomConstants;
import com.azilen.message.boards.model.Children;
import com.azilen.message.boards.model.MainRoot;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.liferay.message.boards.kernel.model.MBCategory;
import com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.WebKeys;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
public class CreateCategoryTree {
	private static final Log _log = LogFactoryUtil.getLog(CreateCategoryTree.class);
	 /**
	  * Function that return all categories in message board portlet
	 */
	
	public static void getAllParentChildCategory(List< List<String>> allChildCategoryList, long groupID,long parentCategoryID,Children parentNode,long selectedCategoryId){
		 _log.debug("Entry:getAllParentChildCategory");
	     List<MBCategory> childCatgoryList = MBCategoryLocalServiceUtil.getCategories(groupID, parentCategoryID,QueryUtil.ALL_POS, QueryUtil.ALL_POS);
	     if(childCatgoryList.size()>0){
	    	 parentNode.setExpanded(true);
	    	 parentNode.setLeaf(false);
	     }
	     else{
	    	 parentNode.setExpanded(false);
	    	 parentNode.setLeaf(true);
	     }
	     for(MBCategory childCategory : childCatgoryList){
	    	 Children childNode = new Children();
	    	 childNode.setLabel(childCategory.getName());
	    	 childNode.setType(CustomConstants.TREE_NODE_TYPE);
	    	 childNode.setId(String.valueOf(childCategory.getCategoryId()));
	    	 if(selectedCategoryId == childCategory.getCategoryId()){
	    		 childNode.setChecked(true);
	    	 }
	    	 else{
	    		 childNode.setChecked(false);
	    	 }
 			parentNode.addChildren(childNode);
	         getAllParentChildCategory(allChildCategoryList, groupID,childCategory.getCategoryId(), childNode,selectedCategoryId);
	     }
	 }
	 
	 
	 /**
	  * Call recursive function that lists all categories and put it in gson
	 */
	public static JsonElement prepareCategoryTree(HttpServletRequest request){
		 _log.debug("Entry:prepareCategoryTree");
		 	long selectedCategoryId=GetterUtil.getLong(request.getAttribute(CustomConstants.SELECTED_CATEGORYID));
		 	MainRoot mainRoot = new MainRoot();
		 	Children masterChild = new Children();
			masterChild.setLabel(CustomConstants.HOME_CATEGORY);
			masterChild.setType(CustomConstants.TREE_NODE_TYPE);
			masterChild.setId(String.valueOf(CustomConstants.ZERO_INDEX));
			if(selectedCategoryId == CustomConstants.ZERO_INDEX){
				masterChild.setChecked(true);
			}
			else{
				masterChild.setChecked(false);
			}
			ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
			
			List<List<String>> allChildCategoryList = new ArrayList<List<String>>();
			getAllParentChildCategory(allChildCategoryList, themeDisplay.getScopeGroupId(), CustomConstants.ZERO_INDEX,masterChild,selectedCategoryId);
			List<Children> categoryPassList = new ArrayList<Children>();
			categoryPassList.add(masterChild);
			mainRoot.addChild(masterChild);
			Gson categoryGson = new Gson();
			JsonElement categoryTree = categoryGson.toJsonTree(categoryPassList);
			return categoryTree;
	 }
	 
}
