package com.message.board.configuration;

import com.message.board.util.Constant;

import aQute.bnd.annotation.metatype.Meta;

/**
 * @author nirali.joshi
 * Interface that represent the configuration
 */
@Meta.OCD(id = Constant.CONFIGURATION_PID)
public interface MBConfig {
	
	 public static final String FIELD_CATEGORY="categoryName";
     
     @Meta.AD(required = false)
     public String getCategory();
}
