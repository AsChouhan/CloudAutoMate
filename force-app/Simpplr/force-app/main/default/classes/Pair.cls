public with sharing class Pair implements Comparable {
	
	public String id{get;set;}
	public String name{get;set;}
	
	public Pair() {
	}
	
	public Pair(String id, String name){
		this.id = id;
		this.name = name;
	}
	
	public Integer compareTo(Object compareToObj) {
    	Pair obj = (Pair)compareToObj;
        return this.id.compareTo(obj.id);     
	}
}