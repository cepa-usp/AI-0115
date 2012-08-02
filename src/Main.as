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
		private var g_xmin:Number = -10;
		private var g_xmax:Number = 10;
		private var g_xsize:int = 595;
		private var g_ymin:Number = -8;
		private var g_ymax:Number = 8;
		private var g_ysize:int = 430;
		private var graphFunction:GraphFunction;
		
		private var a:Number = 1;
		private var b:Number = 1;
		private var c:Number = 1;
		private var reta:Shape;
		private var hasFunction:Boolean = false;
		private var hasData:Boolean = false;
		private var dataStyle:DataStyle = new DataStyle();
		private var dataArray:Array;
		
		private var maxZoom:int = 100;
		private var zoomFactory:Number = 0.1;
		
		override protected function init():void {
            if (ExternalInterface.available) {
				ExternalInterface.addCallback("setA", setA);
				ExternalInterface.addCallback("setB", setB);
				ExternalInterface.addCallback("setC", setC);
				ExternalInterface.addCallback("getA", getA);
				ExternalInterface.addCallback("getB", getB);
				ExternalInterface.addCallback("getC", getC);
				ExternalInterface.addCallback("update", update);
				ExternalInterface.addCallback("reseta", reset);
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
			g.x = 10 + 320 - g_xsize / 2;
			g.y = 240 - g_ysize / 2;
			g.grid = false;
			g.pan = true;
			
			g.addEventListener("initPan", initPan);
			
			g.setTicksDistance(SimpleGraph.AXIS_X, 1);
			g.setTicksDistance(SimpleGraph.AXIS_Y, 1);
			//g.setSubticksDistance(SimpleGraph.AXIS_X, 1/2);
			//g.setSubticksDistance(SimpleGraph.AXIS_Y, 1/2);
			
			graphFunction = new GraphFunction(g_xmin, g_xmax, f);
			
			update();
			
			//stage.addEventListener(MouseEvent.MOUSE_WHEEL, zoom);
		}
		
		private function initPan(e:Event):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
			g.addEventListener("endPan", endPan);
		}
		
		private function panning(e:MouseEvent):void 
		{
			if(hasFunction){
				g.removeFunction(graphFunction);
				graphFunction = new GraphFunction(g.xmin, g.xmax, f);
				g.addFunction(graphFunction, dataStyle);
			}
			if (hasData) {
				g.removeData(dataArray);
				dataArray = [[-c/a, g.ymin], [-c/a, g.ymax]];
				g.addData(dataArray, dataStyle);
			}
		}
		
		private function endPan(e:Event):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			g.removeEventListener("endPan", endPan);
		}
		
		private function zoom(e:MouseEvent):void 
		{
			var tick:Number;
			if (e.delta < 0) {
				if (g.xmax < maxZoom * g_xmax) {
					g.setRange(g.xmin * (1 + zoomFactory), g.xmax * (1 + zoomFactory), g.ymin * (1 + zoomFactory), g.ymax * (1 + zoomFactory));
				}
				if (g.xmax > maxZoom * g_xmax) {
					g.setRange(g_xmin * maxZoom, g_xmax * maxZoom, g_ymin * maxZoom, g_ymax * maxZoom);
				}
				tick = getTickDistance(g.xmax);
				g.setTicksDistance(SimpleGraph.AXIS_X, tick);
				g.setTicksDistance(SimpleGraph.AXIS_Y, tick);
				g.setSubticksDistance(SimpleGraph.AXIS_X, tick/2);
				g.setSubticksDistance(SimpleGraph.AXIS_Y, tick/2);
				update(true);
			}else {
				if (g.xmin < g_xmin) {
					g.setRange(g.xmin / (1 + zoomFactory), g.xmax / (1 + zoomFactory), g.ymin / (1 + zoomFactory), g.ymax / (1 + zoomFactory));
				}
				if(g.xmin > g_xmin){
					g.setRange(g_xmin, g_xmax, g_ymin, g_ymax);
				}
				tick = getTickDistance(g.xmax);
				g.setTicksDistance(SimpleGraph.AXIS_X, tick);
				g.setTicksDistance(SimpleGraph.AXIS_Y, tick);
				g.setSubticksDistance(SimpleGraph.AXIS_X, tick/2);
				g.setSubticksDistance(SimpleGraph.AXIS_Y, tick/2);
				update(true);
			}
		}
		
		private function getTickDistance(xmax:Number):Number 
		{
			if (xmax <= 100) return Math.floor(xmax / 10);
			else if (xmax <= 1000) return Math.floor(xmax / 100) * 10;
			else return Math.floor(xmax / 200);
		}
		
		public function doNothing ():void {
		}
		
		public function f(x:Number):Number
		{
			if (Math.abs(b) < EPS) return -c/a;
			else return (-a*x/b) - (c/b);
			//else return -(b/a*x) -(c/a);
		}
		
		public function update(changeRange:Boolean = false):void 
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
				dataArray = [[-c/a, g.ymin], [-c/a, g.ymax]];
				g.addData(dataArray, dataStyle);
				hasData = true;
			}else {
				if (hasData) {
					g.removeData(dataArray);
					dataArray = null;
					hasData = false;
				}
				if (!hasFunction) {
					if (changeRange) graphFunction = new GraphFunction(g.xmin, g.xmax, f);
					g.addFunction(graphFunction, dataStyle);
					hasFunction = true;
				}else {
					if (changeRange) {
						g.removeFunction(graphFunction);
						graphFunction = new GraphFunction(g.xmin, g.xmax, f);
						g.addFunction(graphFunction, dataStyle);
					}
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
		
		override public function reset(e:MouseEvent = null):void 
		{
			a = b = c = 1;
			g.setRange(g_xmin, g_xmax, g_ymin, g_ymax);
			//g.setTicksDistance(SimpleGraph.AXIS_X, 1);
			//g.setTicksDistance(SimpleGraph.AXIS_Y, 1);
			//g.setSubticksDistance(SimpleGraph.AXIS_X, 1/2);
			//g.setSubticksDistance(SimpleGraph.AXIS_Y, 1/2);
			update(true);
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