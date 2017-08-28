package com.azilen.message.boards.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Children implements Serializable{
	String label;
	boolean leaf;
	String type;
	boolean expanded;
	String id;
	boolean checked;
	public boolean isChecked() {
		return checked;
	}

	public void setChecked(boolean checked) {
		this.checked = checked;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	List<Children> children = new ArrayList<Children>();
	
	public Children()
	{
	
	}
	
	public Children(String _label, boolean _leaf, String _type)
	{
		this.label = _label;
		this.leaf = _leaf;
		this.type = _type;
		
	}
	
	public boolean isExpanded() {
		return expanded;
	}

	public void setExpanded(boolean expanded) {
		this.expanded = expanded;
	}

	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}
	public boolean isLeaf() {
		return leaf;
	}
	public void setLeaf(boolean leaf) {
		this.leaf = leaf;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public List<Children> getChildren() {
		return children;
	}
	public void setChildren(List<Children> children) {
	this.children = children;
}
	
	public void addChildren(Children child)
	{
		this.children.add(child);
	
	}
}
