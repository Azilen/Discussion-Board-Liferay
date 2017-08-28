package com.azilen.message.boards.list;

import com.azilen.message.boards.constants.CustomConstants;
import com.liferay.message.boards.kernel.model.MBBan;
import com.liferay.message.boards.kernel.model.MBCategory;
import com.liferay.message.boards.kernel.model.MBMessage;
import com.liferay.message.boards.kernel.model.MBThread;
import com.liferay.message.boards.kernel.service.MBBanLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBCategoryLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBCategoryServiceUtil;
import com.liferay.message.boards.kernel.service.MBMessageLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBThreadLocalServiceUtil;
import com.liferay.message.boards.kernel.service.MBThreadServiceUtil;
import com.liferay.portal.kernel.dao.orm.DynamicQuery;
import com.liferay.portal.kernel.dao.orm.DynamicQueryFactoryUtil;
import com.liferay.portal.kernel.dao.orm.Projection;
import com.liferay.portal.kernel.dao.orm.ProjectionFactoryUtil;
import com.liferay.portal.kernel.dao.orm.PropertyFactoryUtil;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.dao.search.SearchContainer;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletPreferencesFactoryUtil;
import com.liferay.portal.kernel.search.Hits;
import com.liferay.portal.kernel.search.Indexer;
import com.liferay.portal.kernel.search.IndexerRegistryUtil;
import com.liferay.portal.kernel.search.SearchContext;
import com.liferay.portal.kernel.search.SearchContextFactory;
import com.liferay.portal.kernel.search.SearchResult;
import com.liferay.portal.kernel.search.SearchResultUtil;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalClassLoaderUtil;
import com.liferay.portal.kernel.util.PropsUtil;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.portlet.PortletPreferences;
import javax.servlet.http.HttpServletRequest;

public class CustomThreadCategoryList {
	private static final Log _log = LogFactoryUtil.getLog(CustomThreadCategoryList .class);
	
	/**
	 * Method that get list of subscribed categories by users
	 */
	public static List<MBCategory> getSubscribedCategoriesList(HttpServletRequest request){
		_log.debug("Entry: getSubscribedCategoriesList");
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		List<MBCategory> selectedCategoryList=new ArrayList<>();
		List<Long> categoryIds=new ArrayList<Long>();
		if(themeDisplay.getPortletDisplay().getPortletName().equalsIgnoreCase(CustomConstants.MESSAGE_BOARDS)){
			PortletPreferences preference=(PortletPreferences)request.getAttribute(CustomConstants.PREFERENCE_REQUEST_ATTRIBUTE);
			long preferenceCatId=GetterUtil.getLong(preference.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS) ));
			List<MBCategory> mbCategoryList= MBCategoryServiceUtil.getSubscribedCategories(themeDisplay.getScopeGroupId(), themeDisplay.getUserId(),QueryUtil.ALL_POS, QueryUtil.ALL_POS);
			if(preferenceCatId != QueryUtil.ALL_POS){
				categoryIds=getPreferenceCatChildList(preferenceCatId, request);
					 for(MBCategory  mbCategory:mbCategoryList){
						 for(Long categoryId:categoryIds){
							 if(mbCategory.getCategoryId() == categoryId){
								 	selectedCategoryList.add(mbCategory);
							 }
						 }
					 }
			}
			else{
				selectedCategoryList=mbCategoryList;
			}
		}
		
			_log.debug("List Size:=>"+selectedCategoryList.size());
		
			return selectedCategoryList;  
	}
	
	/**
	 * Method that get list of subscribed threads by users
	 */
	public static List<MBThread> getSubscribedThreadsList(HttpServletRequest request) throws PortalException{
		_log.debug("Entry: getSubscribedThreadsList");
		List<MBThread> subscribedThreadList=new ArrayList<>();
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		List<Long> categoryIds=new ArrayList<Long>();
		PortletPreferences preference=(PortletPreferences)request.getAttribute(CustomConstants.PREFERENCE_REQUEST_ATTRIBUTE);
		long preferenceCatId=GetterUtil.getLong(preference.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
		List<MBThread> mbThreadList= MBThreadServiceUtil.getGroupThreads(themeDisplay.getScopeGroupId(), themeDisplay.getUserId(),WorkflowConstants.STATUS_APPROVED , true, QueryUtil.ALL_POS,QueryUtil.ALL_POS);
		if(preferenceCatId != QueryUtil.ALL_POS){
			categoryIds=getPreferenceCatChildList(preferenceCatId, request);
			 for(MBThread  mbThread:mbThreadList){
				 for(Long categoryId:categoryIds){
					 if(mbThread.getCategoryId() == categoryId){
						 subscribedThreadList.add(mbThread);
					 }
				 }
			 }
		}
		else{
			subscribedThreadList=mbThreadList;
		}
			_log.debug("List Size:=>"+subscribedThreadList.size());
			return subscribedThreadList;
		
	}
	
	/**
	 * Method that get list of recent posts by users
	 */
	public static List<MBThread> getRecentPosts(HttpServletRequest request) throws PortalException{
		_log.debug("Entry : getRecentPosts");
		long groupThreadsUserId = ParamUtil.getLong(request, CustomConstants.GROUP_THREAD_USERID);
		_log.debug("groupThreadsUserId :=>"+groupThreadsUserId);
		List<MBThread> recentThreadList=new ArrayList<>();
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		List<Long> categoryIds=new ArrayList<Long>();
		Calendar calendar = Calendar.getInstance();
		String offset=PropsUtil.get(CustomConstants.RECENT_POST_DATE_OFFSET);
		PortletPreferences preference=(PortletPreferences)request.getAttribute(CustomConstants.PREFERENCE_REQUEST_ATTRIBUTE);
		long preferenceCatId=GetterUtil.getLong(preference.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
		calendar.add(Calendar.DATE, -(Integer.parseInt(offset)));
		List<MBThread> mbThreadList= MBThreadServiceUtil.getGroupThreads(
				themeDisplay.getScopeGroupId(),groupThreadsUserId,calendar.getTime(), WorkflowConstants.STATUS_APPROVED,QueryUtil.ALL_POS, QueryUtil.ALL_POS);
		if(preferenceCatId != QueryUtil.ALL_POS){
			categoryIds=getPreferenceCatChildList(preferenceCatId, request);
			 for(MBThread  mbThread:mbThreadList){
				 for(Long categoryId:categoryIds){
					 if(mbThread.getCategoryId() == categoryId){
						 	recentThreadList.add(mbThread);
					 }
				 }
			 }
		}
		else{
			recentThreadList=mbThreadList;
		}
			_log.debug("List Size:=>"+recentThreadList.size());
		return recentThreadList;
	}
	
	/**
	 *Method that get list of posts by particular user
	 */
	public static List<MBThread> getMyPosts(HttpServletRequest request) throws PortalException{
		_log.debug("Entry : getMyPosts");
		List<MBThread> myThreadList=new ArrayList<>();
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		List<Long> categoryIds=new ArrayList<Long>();
		PortletPreferences preference=(PortletPreferences)request.getAttribute(CustomConstants.PREFERENCE_REQUEST_ATTRIBUTE);
		long preferenceCatId=GetterUtil.getLong(preference.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
		List<MBThread> mbThreadList=MBThreadServiceUtil.getGroupThreads(themeDisplay.getScopeGroupId(), themeDisplay.getUserId(),  WorkflowConstants.STATUS_ANY, QueryUtil.ALL_POS, QueryUtil.ALL_POS);
		if(preferenceCatId != QueryUtil.ALL_POS){
			categoryIds=getPreferenceCatChildList(preferenceCatId, request);
			 for(MBThread  mbThread:mbThreadList){
				 for(Long categoryId:categoryIds){
					 if(mbThread.getCategoryId() == categoryId){
						 myThreadList.add(mbThread);
					 }
				 }
			 }
		}
		else{
			myThreadList=mbThreadList;
		}
			_log.debug("List Size:=>"+myThreadList.size());
			return myThreadList;
	}
	
	/**
	 * Method that get subcategories of particular category
	 */
	public static List<Object> getMBSubCategories(HttpServletRequest request,long selectedCategoryId){
		_log.debug("Entry : getMBSubCategories");
		List<Object> subCategoryList=new ArrayList<>();
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), CustomConstants.MESSAGE_BOARDS);
		long preferenceCatId=GetterUtil.getLong(preferences.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
		long mbcatID=ParamUtil.getLong(request, "mbCategoryId");
		if(mbcatID !=CustomConstants.ZERO_INDEX){
			selectedCategoryId=mbcatID;
		}
		ParamUtil.getString(request, "mbCategoryId");
		int status = WorkflowConstants.STATUS_APPROVED;
		PermissionChecker permissionChecker =
				themeDisplay.getPermissionChecker();

			if (permissionChecker.isContentReviewer(
					themeDisplay.getCompanyId(),
					themeDisplay.getScopeGroupId())) {

				status = WorkflowConstants.STATUS_ANY;
			}
		subCategoryList= MBCategoryLocalServiceUtil.getCategoriesAndThreads(themeDisplay.getScopeGroupId(), selectedCategoryId, status, QueryUtil.ALL_POS, QueryUtil.ALL_POS);
			_log.debug("List Size:=>"+subCategoryList.size());
		return subCategoryList;
		
	}
	
	/**
	 *Method that get list of results for the keyword search by user
	 */
	public static List<MBThread> getSearchResults(HttpServletRequest request,long searchCategoryId,SearchContainer searchContainer){
		_log.debug("Entry : getSearchResults");
		List<MBThread> threadsList=new ArrayList<>();
		try{
				String keywords = ParamUtil.getString(request, CustomConstants.KEYWORDS);
				ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
				long[] finalSearchCategoryIdsArray = null;
				List<Long> searchCategoryIds = new ArrayList<>();
				List<Long> finalSearchCategoryIds=new ArrayList<>();
				PortletPreferences preference=(PortletPreferences)request.getAttribute(CustomConstants.PREFERENCE_REQUEST_ATTRIBUTE);
				long preferenceCatId=GetterUtil.getLong(preference.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
				List<Long> categoryIds=new ArrayList<Long>();
				MBCategoryServiceUtil.getSubcategoryIds(
						searchCategoryIds, themeDisplay.getScopeGroupId(), searchCategoryId);
				searchCategoryIds.add(Long.valueOf(searchCategoryId));
				if(preferenceCatId != QueryUtil.ALL_POS){
					categoryIds=getPreferenceCatChildList(preferenceCatId, request);
					for(long preferenceCat:categoryIds){
						for(long searchCat:searchCategoryIds){
							if(preferenceCat == searchCat){
								finalSearchCategoryIds.add(searchCat);
							}
						}
					}
				}
				else{
					finalSearchCategoryIds.addAll(searchCategoryIds);
				}
				finalSearchCategoryIdsArray= StringUtil.split(
						StringUtil.merge(finalSearchCategoryIds), 0L);
				
				Indexer indexer = IndexerRegistryUtil.getIndexer(MBMessage.class);
		
				SearchContext searchContext = SearchContextFactory.getInstance(
					request);
		
				searchContext.setAttribute(CustomConstants.PAGINATION_TYPE, CustomConstants.PAGINATION_TYPE_VALUE);
				searchContext.setCategoryIds(finalSearchCategoryIdsArray);
				searchContext.setEnd(searchContainer.getEnd());
				searchContext.setIncludeAttachments(true);
		
				searchContext.setKeywords(keywords);
		
				searchContext.setStart(searchContainer.getStart());
		
				Hits hits = indexer.search(searchContext);
		
				List<SearchResult> searchResults=SearchResultUtil.getSearchResults(hits, request.getLocale());
				
				for(SearchResult searchResult:searchResults){
					threadsList.add(MBThreadLocalServiceUtil.getMBThread(MBMessageLocalServiceUtil.getMBMessage(searchResult.getClassPK()).getThreadId()));
				}
					_log.debug("List Size:=>"+threadsList.size());
				searchContainer.setSearch(true);
				searchContainer.setTotal(hits.getLength());
		}
		catch(Exception e){
			_log.error("Exception while searching",e);
		}
	return threadsList;
	}
	
	/**
	 * Method that get list of banned users
	 */
	public static List<MBBan> getBannedUsersList(HttpServletRequest request) throws PortalException{
		_log.debug("Entry:getBannedUsersList");
		ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(WebKeys.THEME_DISPLAY);
		List<MBBan> banUsersList=MBBanLocalServiceUtil.getBans(themeDisplay.getScopeGroupId(),QueryUtil.ALL_POS, QueryUtil.ALL_POS);
		List<MBBan> banUsersSelectedCategoryList=new ArrayList<>();
		Map<MBBan,Long> catUserMap=new HashMap<MBBan,Long>();
		PortletPreferences preferences = PortletPreferencesFactoryUtil.getLayoutPortletSetup(themeDisplay.getLayout(), CustomConstants.MESSAGE_BOARDS);
		long preferenceCatId=GetterUtil.getLong(preferences.getValue(CustomConstants.PREFERENCE_CATEGORYID, String.valueOf(QueryUtil.ALL_POS)));
		List<Long> preferenceCatList=new ArrayList<Long>();
		if(preferenceCatId != QueryUtil.ALL_POS){
			preferenceCatList=getPreferenceCatChildList(preferenceCatId,request);
		}
		for(MBBan banUser:banUsersList){
			DynamicQuery dynamicQuery = DynamicQueryFactoryUtil.forClass(MBThread.class, PortalClassLoaderUtil.getClassLoader());
			dynamicQuery.add(PropertyFactoryUtil.forName(CustomConstants.USERID).eq(banUser.getBanUserId()));
			Projection projection=ProjectionFactoryUtil.distinct(ProjectionFactoryUtil.property(CustomConstants.THREAD_CATEGORYID));
			dynamicQuery.setProjection(projection);
			 List<Long> categories=MBThreadLocalServiceUtil.dynamicQuery(dynamicQuery);
			 for(Long cat:categories){
				 catUserMap.put(banUser, cat);
			 }
		}
		banUsersSelectedCategoryList=getBanUerList(catUserMap,preferenceCatList,banUsersSelectedCategoryList);
		
		return banUsersSelectedCategoryList;
		
	}
	/**
	 * Method that prepare list of ban users for selected category in preference
	 */
	public static List<MBBan> getBanUerList(Map<MBBan,Long> catUserMap,List<Long> preferenceCatList,List<MBBan> banUsersSelectedCategoryList){
		_log.debug("Entry:getBanUerList");
		for(Map.Entry<MBBan,Long> entry : catUserMap.entrySet()){
			if(!preferenceCatList.isEmpty()){
				for(long preferenceCat:preferenceCatList){
					if(preferenceCat == entry.getValue()){
						banUsersSelectedCategoryList.add(entry.getKey());
					}
				}
			}
			else{
				banUsersSelectedCategoryList.add(entry.getKey());
			}
		}
			_log.debug("List Size:=>"+banUsersSelectedCategoryList.size());
		return banUsersSelectedCategoryList;
	}
	
	/**
	 * Method that prepare list of child categories of selected category in preference
	 */
	public static List<Long> getPreferenceCatChildList(long preferenceCatId,HttpServletRequest request){
		_log.debug("Entry:getPreferenceCatChildList");
		long groupId=GetterUtil.getLong(request.getAttribute("groupId"));
		List<Long> categoryIds=new ArrayList<>();
		 categoryIds.add(preferenceCatId);
		 List<Long> preferenceChildCategoryIds= MBCategoryLocalServiceUtil.getSubcategoryIds(categoryIds, groupId, preferenceCatId);
		 _log.debug("List Size:=>"+categoryIds.size());
		return preferenceChildCategoryIds;
	}
}
