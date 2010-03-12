package net.kandov.reflexutil.types
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;

	public class MethodInfo extends EventDispatcher implements IComparable
	{
		public var component:DisplayObjectContainer;
		public var name:String;
		public var declaredBy:String;
		public var returnType:String;
		public var parameter:Array;
		
		public function MethodInfo(component:DisplayObjectContainer, name:String, declaredBy:String, returnType:String, parameter:Array = null)
		{
			super();
			
			this.component = component;
			this.name = name;
			this.declaredBy = declaredBy;
			this.returnType = returnType;
			this.parameter = parameter;
		}
		
		public function equals(anotherObject:Object):Boolean {
			var anotherMethodeInfo:MethodInfo = anotherObject as MethodInfo;
			 if (anotherMethodeInfo) {
				return anotherMethodeInfo.component == component &&
					anotherMethodeInfo.name == name;
			} 
			return false;
		}
		
	}
}