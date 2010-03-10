package net.kandov.reflexutil.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Image;
	import mx.controls.Tree;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.ListEvent;

	[Event(name="gotoParentObjectIconClicked", type="flash.events.Event")]
	[Event(name="showHideIconClicked", type="flash.events.Event")]

	public class ComponentTree extends Tree
	{
		public static const GOTO_PARENT_OBJECT_ICON_CLICKED:String = 'gotoParentObjectIconClicked';
		public static const SHOW_HIDE_ICON_CLICKED:String = 'showHideIconClicked';
		
		public function ComponentTree()
		{
			super();
		}
		
		override protected function mouseClickHandler(event:MouseEvent):void
	    {
	        var item:IListItemRenderer = mouseEventToItemRenderer(event);
	        if (!item)
	            return;
	
	        var pt:Point = itemRendererToIndices(item);
	        if (pt) // during tweens, we may get null
	        {
        		var image:Image = event.target as Image;
	        	if(image ) {
					if(image.id == ComponentInfoItemRenderer.GOTO_PARENT_OBJECT_ICON) {
			        	dispatchEvent(new Event(GOTO_PARENT_OBJECT_ICON_CLICKED));  
					}	        		
					if(image.id == ComponentInfoItemRenderer.SHOW_HIDE_ICON) {
			        	dispatchEvent(new Event(SHOW_HIDE_ICON_CLICKED));  
					}	        		
	        	}
	            var listEvent:ListEvent =
	                new ListEvent(ListEvent.ITEM_CLICK);
	            listEvent.columnIndex = pt.x;
	            listEvent.rowIndex = pt.y;
	            listEvent.itemRenderer = item;
	            dispatchEvent(listEvent);
	        }
	    }
	}
}