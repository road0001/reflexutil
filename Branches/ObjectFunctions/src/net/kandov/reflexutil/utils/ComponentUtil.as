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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	
	import net.kandov.reflexutil.components.ComponentHover;
	import net.kandov.reflexutil.types.ComponentInfo;
	import net.kandov.reflexutil.types.MethodInfo;
	import net.kandov.reflexutil.types.ParameterInfo;
	import net.kandov.reflexutil.types.PropertyInfo;
	
	public class ComponentUtil {
		
		public static const CUSTOM_FORMAT_TYPES:Array = ["Color"];
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public static function getHolderComponent(displayObject:DisplayObject):UIComponent {
			if (displayObject is UIComponent) {
				return UIComponent(displayObject);
			} else {
				if (displayObject.parent) {
					return getHolderComponent(displayObject.parent);
				} else {
					return null;
				}
			}
		}
		
		public static function getColorUnderMouse(stage:DisplayObjectContainer,container:DisplayObjectContainer):uint {
			 var bd:BitmapData = new BitmapData(stage.width, stage.height);  
			 bd.draw(stage);    
			 var b:Bitmap = new Bitmap(bd);
			 return b.bitmapData.getPixel(container.mouseX,container.mouseX);
		}
		
		public static function getComponentsUnderMouse(container:DisplayObjectContainer):Array {
			var components:Array = new Array;
			
			var displayObjects:Array = container.getObjectsUnderPoint(
				new Point(container.stage.mouseX, container.stage.mouseY));
			
			for each (var displayObject:DisplayObject in displayObjects) {
				var component:UIComponent = getHolderComponent(displayObject);
				if (component && components.indexOf(component) == -1) {
					components.push(component);
				}
			}
			
			return components;
		}
		
		public static function getUID(component:DisplayObjectContainer):String {
			var uicomponent:UIComponent = component as UIComponent;
			var uid:String = 'DisplayObjectContainer';
			if(uicomponent) {
				uid = uicomponent.uid;
				if (uid.indexOf(".") != -1) {
					var strArr:Array = uid.split(".");
					uid = strArr[strArr.length - 1];
				}
			}	
			return uid;
		}
		
		public static function getAbsolutePosition(component:DisplayObjectContainer):Point {
			var nativeParent:DisplayObjectContainer = component.mx_internal::$parent;
			if(nativeParent){
				return nativeParent.localToGlobal(new Point(component.x, component.y));
			}
			return new Point();
		}
		
		public static function getRootComponentInfo(componentInfo:ComponentInfo):ComponentInfo {
			if (!componentInfo) {
				return null;
			}
			
			if (componentInfo.parent) {
				return getRootComponentInfo(componentInfo.parent);
			} else {
				return componentInfo;
			}
		}
		
		public static function generateComponentInfo(component:DisplayObjectContainer):ComponentInfo {
			var componentInfo:ComponentInfo = new ComponentInfo(
				component, getUID(component) + " (" + ClassUtil.getClassName(component) + ")");
			
			if (component.numChildren != 0) {
				var child:DisplayObject;
				for (var i:int = 0; i < component.numChildren; i ++) {
					child = component.getChildAt(i);
					
					if (child is UIComponent && !(child is ComponentHover)) {
						if (!componentInfo.children) {
							componentInfo.children = new Array();
						}
						
						var childComponentInfo:ComponentInfo = generateComponentInfo(UIComponent(child));
						childComponentInfo.parent = componentInfo;
						componentInfo.children.push(childComponentInfo);
					}
				}
			}
			var type:XML = describeType(component);
			componentInfo.propertiesInfos = generatePropertiesInfos(component,type);
			componentInfo.methodsInfos = generateMethodsInfos(component,type);
			
			return componentInfo;
		}
		
		public static function generateMethodsInfos(component:DisplayObjectContainer,type:XML):Array {
			var methodsInfos:Array = new Array();
			
			var methodInfo:MethodInfo;
			var value:Object;
			
			//get properties
			
			var methods:XMLList = type.method;
			var method:XML;
			var parameter:XML;
			var parameters:Array = [];
			var parameterInfo:ParameterInfo;
			var uniqueMethods:XMLList = new XMLList();
			for each (method in methods) {
				if (!uniqueMethods.contains(method)) {
					uniqueMethods += method;
				}
			}
			
			if (uniqueMethods.length() != 0) {
				for each (method in uniqueMethods) {
					methodInfo = new MethodInfo(
						component, method.@name, method.@declaredBy,  method.@returnType);
					if(method.@parameter){
						for each (parameter in method.children()){
							parameterInfo = new ParameterInfo(
								component, method.@name, parameter.@index, parameter.@type, parameter.@optional);
							parameters.push(parameterInfo);
						}
						methodInfo.parameter = parameters;
					}
					methodsInfos.push(methodInfo);
				}
			}
			
			//get parameters
			
			/* var styles:XMLList = type.metadata.(attribute("name") == "Style");
			for each (var extendsClass:XML in type.extendsClass) {
				try {
					var extendsClassType:XML = describeType(new (getDefinitionByName(extendsClass.@type)));
					styles += extendsClassType.metadata.(attribute("name") == "Style");
				} catch (error:Error) {
					//cannot instantiate this type of class
				}
				
				if (extendsClass.@type == "mx.core::UIComponent") {
					break;
				}
			}
			
			var style:XML;
			var uniqueStyles:XMLList = new XMLList();
			for each (style in styles) {
				if (!uniqueStyles.contains(style)) {
					uniqueStyles += style;
				}
			}
			
			if (uniqueStyles.length() != 0) {
				var styleArgs:Object;
				for each (style in uniqueStyles) {
					styleArgs = new Object();
					for each (var arg:XML in style.arg) {
						styleArgs[arg.@key] = arg.@value;
					}
					
					propertyInfo = new PropertyInfo(component, styleArgs.name, styleArgs.type, true);
					
					if (styleArgs.hasOwnProperty("enumeration")) {
						propertyInfo.type = "Enumeration";
						propertyInfo.enumeration = String(styleArgs.enumeration).split(",");
					} else if (CUSTOM_FORMAT_TYPES.indexOf(String(styleArgs.format)) != -1) {
						propertyInfo.type = styleArgs.format;
					} else {
						propertyInfo.type = styleArgs.type;
					}
					
					getPropertyValue(propertyInfo);
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			propertiesInfos.push(new PropertyInfo(component, "top", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "bottom", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "left", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "right", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "horizontalCenter", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "verticalCenter", "Number", true)); */
			
			return methodsInfos;
		}
		public static function generatePropertiesInfos(component:DisplayObjectContainer,type:XML):Array {
			var propertiesInfos:Array = new Array();
			
			var propertyInfo:PropertyInfo;
			var value:Object;
			
			//get properties
			
			var properties:XMLList = type.accessor;
			var property:XML;
			var uniqueProperties:XMLList = new XMLList();
			for each (property in properties) {
				if (!uniqueProperties.contains(property)) {
					uniqueProperties += property;
				}
			}
			
			if (uniqueProperties.length() != 0) {
				for each (property in uniqueProperties) {
					propertyInfo = new PropertyInfo(
						component, property.@name, property.@type, false, property.@access, property.@uri);
					
					var metadataCollection:XMLList = property["metadata"];
					for each (var metadata:XML in metadataCollection) {
						if (metadata.@name == "Bindable") {
							propertyInfo.bindable = true;
							break;
						}
					}
					
					getPropertyValue(propertyInfo);
					
					//FIXME: data property causes stack overflow exception which is not catched
					if (propertyInfo.bindable && propertyInfo.access != "writeonly" &&
						propertyInfo.uri != PropertyInfo.URI_MX_INTERNAL && propertyInfo.name != "data") {
						try {
							BindingUtils.bindProperty(propertyInfo, "value", component, propertyInfo.name);
						} catch (error:Error) {
							//cannot bind value from component's property
							propertyInfo.bindable = false;
						}
					}
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			//get styles
			
			var styles:XMLList = type.metadata.(attribute("name") == "Style");
			for each (var extendsClass:XML in type.extendsClass) {
				try {
					var extendsClassType:XML = describeType(new (getDefinitionByName(extendsClass.@type)));
					styles += extendsClassType.metadata.(attribute("name") == "Style");
				} catch (error:Error) {
					//cannot instantiate this type of class
				}
				
				if (extendsClass.@type == "mx.core::UIComponent") {
					break;
				}
			}
			
			var style:XML;
			var uniqueStyles:XMLList = new XMLList();
			for each (style in styles) {
				if (!uniqueStyles.contains(style)) {
					uniqueStyles += style;
				}
			}
			
			if (uniqueStyles.length() != 0) {
				var styleArgs:Object;
				for each (style in uniqueStyles) {
					styleArgs = new Object();
					for each (var arg:XML in style.arg) {
						styleArgs[arg.@key] = arg.@value;
					}
					
					propertyInfo = new PropertyInfo(component, styleArgs.name, styleArgs.type, true);
					
					if (styleArgs.hasOwnProperty("enumeration")) {
						propertyInfo.type = "Enumeration";
						propertyInfo.enumeration = String(styleArgs.enumeration).split(",");
					} else if (CUSTOM_FORMAT_TYPES.indexOf(String(styleArgs.format)) != -1) {
						propertyInfo.type = styleArgs.format;
					} else {
						propertyInfo.type = styleArgs.type;
					}
					
					getPropertyValue(propertyInfo);
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			propertiesInfos.push(new PropertyInfo(component, "top", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "bottom", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "left", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "right", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "horizontalCenter", "Number", true));
			propertiesInfos.push(new PropertyInfo(component, "verticalCenter", "Number", true));
			
			return propertiesInfos;
		}
		
		public static function getPropertyValue(propertyInfo:PropertyInfo):void {
			var uicomponent:UIComponent = propertyInfo.component as UIComponent;
			if(uicomponent){
				if (!propertyInfo.bindable) {
					try {
						if (propertyInfo.isStyle) {
							propertyInfo.value = uicomponent.getStyle(propertyInfo.name);
						} else if (propertyInfo.access != "writeonly" &&
							propertyInfo.uri != PropertyInfo.URI_MX_INTERNAL) {
							propertyInfo.value = uicomponent[propertyInfo.name];
						}
					} catch (error:Error) {
						//cannot get value from component's property or style
					}
				}
			}
		}
		
		public static function setPropertyValue(propertyInfo:PropertyInfo, value:Object):void {
			var uicomponent:UIComponent = propertyInfo.component as UIComponent;
			if(uicomponent){
				try {
					if (propertyInfo.isStyle) {
						uicomponent.setStyle(propertyInfo.name, value);
					} else {
						uicomponent[propertyInfo.name] = value;
					}
				} catch (error:Error) {
					//cannot set value to component's property or style
				}
				finally {
					getPropertyValue(propertyInfo);
				}
			} else {
				getPropertyValue(propertyInfo);
			}
		}
		
	}
	
}