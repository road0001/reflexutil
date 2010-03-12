package net.kandov.reflexutil.components
{
	import flash.display.Graphics;
	
	import mx.controls.Image;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	import net.kandov.reflexutil.types.ComponentInfo;

	public class ComponentInfoItemRenderer extends TreeItemRenderer
	{
		public static const GOTO_PARENT_OBJECT_ICON:String = 'gotoParentObjectIcon';
		public static const SHOW_HIDE_ICON:String = 'showHideIcon';
		
		[Embed(source="../assets/folderParent.png")]
		[Bindable]
		public var gotoParentObjectIconClass:Class;
		[Embed(source="../assets/openedBox.png")]
		[Bindable]
		public var showIconClass:Class;
		[Embed(source="../assets/closedBox.png")]
		[Bindable]
		public var hideIconClass:Class;
		
		protected var _componentInfo:ComponentInfo;
		
		protected var gotoParentObjectIcon:Image;
		protected var showHideIcon:Image;
		
		public function ComponentInfoItemRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void{
			componentInfo = value as ComponentInfo;
			super.data = value;
		}
		
		protected function get componentInfo():ComponentInfo {
			return _componentInfo;
		}
		
		protected function set componentInfo(value:ComponentInfo):void {
			if(_componentInfo != value){
				_componentInfo = value;
				if(showHideIcon){
					if(_componentInfo && _componentInfo.component){
							showHideIcon.source = _componentInfo.component.visible ? hideIconClass : showHideIcon;
					
					} else {
						showHideIcon.source = null;
					}
				}
			}
		}
		
		override protected function createChildren():void
		{
	        super.createChildren();
	        createIcons();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var g:Graphics = graphics;
			//boundingBox
			g.beginFill(0,0);
			g.drawRect(0,0,unscaledWidth,unscaledHeight);
			g.endFill();
			
        	var posX:Number = label.x + label.width - 20;
			if (gotoParentObjectIcon)
	        {
	        	gotoParentObjectIcon.x = posX;
	        	gotoParentObjectIcon.y = label.y;
	        }
			if (showHideIcon)
	        {
	        	showHideIcon.x = posX - gotoParentObjectIcon.width - 2;
	        	showHideIcon.y = label.y;
	        }
		}
		
		protected function createIcons():void {
			if (!gotoParentObjectIcon)
	        {
				gotoParentObjectIcon = new Image();
				gotoParentObjectIcon.id	 = "gotoParentObjectIcon";
				gotoParentObjectIcon.styleName = this;
				gotoParentObjectIcon.source = gotoParentObjectIconClass;
				gotoParentObjectIcon.toolTip = "Goto Parent Object";
				gotoParentObjectIcon.width = 16;
				gotoParentObjectIcon.height = 16;
				
	            addChild(gotoParentObjectIcon);
	        }
			if (!showHideIcon)
	        {
				showHideIcon = new Image();
				showHideIcon.styleName = this;
				showHideIcon.id	 = "showHideIcon";
				showHideIcon.toolTip = "Show Or Hide Object";
				//showHideIcon.source = showIconClass;
				showHideIcon.width = 16;
				showHideIcon.height = 16;
				
	            addChild(showHideIcon);
	        }
		}	
	}
}