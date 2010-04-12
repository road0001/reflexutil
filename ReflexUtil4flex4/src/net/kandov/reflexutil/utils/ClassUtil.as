/*
*	Copyright 2007 Alon Kandov (kandov@gmail.com)
*	ReflexUtil <http://reflexutil.googlecode.com>
*	
*	==========================================================================
*	
*	This file is part of ReflexUtil.
*	
*	ReflexUtil is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*	
*	ReflexUtil is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*	
*	You should have received a copy of the GNU General Public License
*	along with ReflexUtil.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.kandov.reflexutil.utils {
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class ClassUtil {
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public static function getClassName(object:Object):String {
	        var name:String = getQualifiedClassName(object);
	        
			var index:int;
			if ((index = name.indexOf ("::")) != -1) {
				name = name.substr(index + 2);
			} else if ((index = name.indexOf ('as$')) != -1){
				name = name.slice(index + 3);
			}
	        
	        return name;
		}
		
		public static function newSibling(sourceObj:Object):* {
	         if(sourceObj) {
	 
	             var objSibling:*;
	             try {
	                 var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
	                 objSibling = new classOfSourceObj();
	             }
	 
	             catch(e:Object) {}
	 
	             return objSibling;
	         }
	         return null;
	     }
	 
	     public static function clone(source:Object):Object {
	 
	         var clone:Object;
	         if(source) {
	             clone = newSibling(source);
	 
	             if(clone) {
	                 copyData(source, clone);
	             }
	         }
	 
	         return clone;
	     }
	 
	     public static function copyData(source:Object, destination:Object):void {
	 
	         //copies data from commonly named properties and getter/setter pairs
	         if((source) && (destination)) {
	 
	             try {
	                 var sourceInfo:XML = describeType(source);
	                 var prop:XML;
	 
	                 for each(prop in sourceInfo.variable) {
	 
	                     if(destination.hasOwnProperty(prop.@name)) {
	                         destination[prop.@name] = source[prop.@name];
	                     }
	 
	                 }
	 
	                 for each(prop in sourceInfo.accessor) {
	                     if(prop.@access == "readwrite") {
	                         if(destination.hasOwnProperty(prop.@name)) {
	                             destination[prop.@name] = source[prop.@name];
	                         }
	 
	                     }
	                 }
	             }
	             catch (err:Object) {
	                 ;
	             }
	         }
	     }
	}

}