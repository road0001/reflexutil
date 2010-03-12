package net.kandov.reflexutil.types
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;

	public class ParameterInfo extends EventDispatcher implements IComparable
	{
		public var component:DisplayObjectContainer;
		public var methodName:String;
		public var index:int;
		public var type:String;
		public var optional:Boolean;
		
		public function ParameterInfo(component:DisplayObjectContainer, methodName:String, index:int, type:String, optional:Boolean)
		{
			super();
			
			this.component = component;
			this.methodName = methodName;
			this.index = index;
			this.type = type;
			this.optional = optional;
		}
		
		public function equals(anotherObject:Object):Boolean {
			var anotherParameterInfo:ParameterInfo = anotherObject as ParameterInfo;
			 if (anotherParameterInfo) {
				return anotherParameterInfo.component == component &&
					anotherParameterInfo.methodName == methodName;
			} 
			return false;
		}
		
	}
}