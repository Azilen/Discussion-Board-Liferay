package com.azilen.message.boards.model;

import java.util.ArrayList;
import java.util.List;

public class MainRoot {
	
	List<Children> children = new ArrayList<Children>();

	public List<Children> getChildren() {
		return children;
	}

	public void addChild(Children child) {
		this.children.add(child);
	}


	public void setChildren(List<Children> children) {
		this.children = children;
	}

}
