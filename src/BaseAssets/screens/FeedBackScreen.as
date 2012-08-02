package BaseAssets.screens
{
	import BaseAssets.events.BaseEvent;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Elastic;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class FeedBackScreen extends MovieClip
	{
		private var glassPane:GlassPane;
		public var okCancelMode:Boolean = false;
		
		public function FeedBackScreen(glass:GlassPane) 
		{
			glassPane = glass;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			this.x = stage.stageWidth / 2;
			this.y = stage.stageHeight / 2;
			
			this.okButton.mouseChildren = false;
			this.okButton.addEventListener(MouseEvent.CLICK, closeScreen);
			this.cancelButton.addEventListener(MouseEvent.CLICK, closeScreen);
			stage.addEventListener(KeyboardEvent.KEY_UP, escCloseScreen);
			
			this.scaleX = this.scaleY = 0;
			this.visible = false;
		}
		
		private function escCloseScreen(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ESCAPE) {
				if (this.visible) closeScreen(null);
			}
		}
		
		private function closeScreen(e:MouseEvent):void 
		{
			Actuate.tween(glassPane, 0.4, { scaleX:0, scaleY:0 } );
			Actuate.tween(this, 0.4, { scaleX:0, scaleY:0 } ).onComplete(turnInvisible);
			if (e != null) {
				if(e.target == okButton) dispatchEvent(new BaseEvent(BaseEvent.OK_SCREEN, true));
			}
		}
		
		private function turnInvisible():void 
		{
			this.visible = false;
			glassPane.visible = false;
			dispatchEvent(new BaseEvent(BaseEvent.CLOSE_SCREEN, true));
		}
		
		public function openScreen():void
		{
			cancelButton.visible = okCancelMode;
			
			glassPane.x = this.x;
			glassPane.y = this.y;
			glassPane.scaleX = glassPane.scaleY = 0;
			this.visible = true;
			glassPane.visible = true;
			Actuate.tween(glassPane, 0.4, { scaleX:1, scaleY:1 } );
			Actuate.tween(this, 0.6, { scaleX:1, scaleY:1 } ).ease(Elastic.easeOut);
		}
		
		public function setText(texto:String):void
		{
			this.texto.text = texto;
			openScreen();
		}
		
	}

}