package net.kandov.reflexutil.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	
	import net.kandov.reflexutil.types.MethodInfo;

	public class ExecuteFunctionItemRenderer extends Button
	{
		protected var _methodInfo:MethodInfo;
		
		public function ExecuteFunctionItemRenderer()
		{
			super();
			width = 16;
			height = 16;
			label = '*';
			addEventListener(MouseEvent.CLICK, btnClickHandler);
		}
		
		override public function set data(value:Object):void {
			methodInfo = value as MethodInfo;
			super.data = value;
		}
		
		protected function get methodInfo():MethodInfo {
			return _methodInfo; 
		}
		protected function set methodInfo(value:MethodInfo):void {
			if(_methodInfo != value) {
				_methodInfo = value;
				if(_methodInfo && _methodInfo.component && _methodInfo.returnType == "void" ){
					if(!_methodInfo.parameter){
						enabled = true;
						visible = true;
					} else {
						if(_methodInfo.parameter.length > 0){
							enabled = false;
							visible = false;
						} else {
							enabled = true;
							visible = true;
						} 
					}
				} else {
					enabled = false;
					visible = false;
				} 
			} 
		}
		protected function btnClickHandler(e:Event):void {
			e.stopImmediatePropagation();
			if(methodInfo && methodInfo.component && methodInfo.returnType == "void" ){
				if(!methodInfo.parameter){
					executeFunction();
				} else {
					if(methodInfo.parameter.length < 1){
						executeFunction();
					}
				}
			}  
		}
		protected function executeFunction():void {
			methodInfo.component[methodInfo.name].call();
		}
		
		
	}
}