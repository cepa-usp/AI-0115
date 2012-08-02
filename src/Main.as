package  
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.DataStyle;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.events.Event;
	import cepa.graph.rectangular.SimpleGraph;
	import cepa.graph.GraphFunction;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;

    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Luciano
	 */
	public class Main extends BaseMain
	{
		private var g:SimpleGraph;
		private var g_xmin:Number = -5;
		private var g_xmax:Number = 5;
		private var g_xsize:int = 400;
		private var g_ymin:Number = -5;
		private var g_ymax:Number = 5;
		private var g_ysize:int = 400;
		private var graphFunction:GraphFunction;
		
		private var a:Number = 1;
		private var b:Number = 1;
		private var c:Number = 1;
		private var reta:Shape;
		private var hasFunction:Boolean = false;
		private var hasData:Boolean = false;
		private var dataStyle:DataStyle = new DataStyle();
		private var dataArray:Array;
		
		override protected function init():void {
            if (ExternalInterface.available) {
				ExternalInterface.addCallback("setA", setA);
				ExternalInterface.addCallback("setB", setB);
				ExternalInterface.addCallback("setC", setC);
				ExternalInterface.addCallback("getA", getA);
				ExternalInterface.addCallback("getB", getB);
				ExternalInterface.addCallback("getC", getC);
				ExternalInterface.addCallback("update", update);
				ExternalInterface.addCallback("reseta", reseta);
				ExternalInterface.addCallback("f", f);
				ExternalInterface.addCallback("doNothing", doNothing);
			}
			
			if (!isNaN(Number(root.loaderInfo.parameters["a"]))) {
				a = Number(root.loaderInfo.parameters["a"]);
			}
			if (!isNaN(Number(root.loaderInfo.parameters["b"]))) {
				b = Number(root.loaderInfo.parameters["b"]);
			}
			if (!isNaN(Number(root.loaderInfo.parameters["c"]))) {
				c = Number(root.loaderInfo.parameters["c"]);
			}
			
			if (Math.abs(a) < EPS && Math.abs(b) < EPS) {
				a = 1;
				b = 1;
			}
			
			g = new SimpleGraph(g_xmin, g_xmax, g_xsize, g_ymin, g_ymax, g_ysize);
			addChild(g);
			g.x = 320 - g_xsize / 2;
			g.y = 240 - g_ysize / 2;
			g.grid = false;
			g.setTicksDistance(SimpleGraph.AXIS_X, 1);
			g.setTicksDistance(SimpleGraph.AXIS_Y, 1);
			graphFunction = new GraphFunction(g_xmin, g_xmax, f);
			//g.addFunction(graphFunction, dataStyle);
			//hasFunction = true;
			
			//g.draw();
			update();
			
			//iniciaTutorial();
			//desenhaReta();
		}
		
		public function doNothing ():void {
		}
		
		public function f(x:Number):Number
		{
			if (Math.abs(b) < EPS) return -c/a;
			else return (-a*x/b) - (c/b);
			//else return -(b/a*x) -(c/a);
		}
		
		public function reseta():void 
		{
			a = b = c = 1;
			g.draw();
		}
		
		public function update():void 
		{
			if (Math.abs(b) < EPS) {
				if (hasFunction) {
					g.removeFunction(graphFunction);
					hasFunction = false;
				}
				if (hasData) {
					g.removeData(dataArray);
					dataArray = null;
					hasData = false;
				}
				dataArray = [[-c/a, g_ymin], [-c/a, g_ymax]];
				g.addData(dataArray, dataStyle);
				hasData = true;
			}else {
				if (hasData) {
					g.removeData(dataArray);
					dataArray = null;
					hasData = false;
				}
				if (!hasFunction) {
					g.addFunction(graphFunction, dataStyle);
					hasFunction = true;
				}
			}
			g.draw();
		}
		
		public function getA():Number
		{
			return this.a;
		}
		
		public function getB():Number
		{
			return this.b;
		}
		
		public function getC():Number
		{
			return this.c;
		}
		
		private const EPS:Number = 0.0001;
		
		public function setA(a:Number, _update:Boolean):void
		{
			if (Math.abs(a) < EPS && Math.abs(this.b) < EPS) {
				throw new Error ("warning: 'a' and 'b' cannot be both zero.");
			}
			else {
				this.a = a;
				if (_update) update();
			}
		}
		
		public function setB(b:Number, _update:Boolean):void
		{
			if (Math.abs(this.a) < EPS && Math.abs(b) < EPS) {
				throw new Error ("warning: 'a' and 'b' cannot be both zero.");
			}
			else {
				this.b = b;
				if (_update) update();
			}
		}
		
		public function setC(c:Number, _update:Boolean):void
		{
			if (isNaN(c)) c = 1;
			this.c = c;
			if (_update) update();
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Veja as orientações aqui."];
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto();
				layerTuto.addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(520, 380)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.CENTER]];
			}
			
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(BaseEvent.NEXT_BALAO, closeBalao);
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
				balao.visible = false;
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
	}

}