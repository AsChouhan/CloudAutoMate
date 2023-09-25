Simpplr.Salesforce.Dashboard = {
  	
  	getTileList :function (data) {
      return Simpplr.Salesforce.sendRequest({
          data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=getTileList'
      });
  	},
  
  	getTile :function (data, tileId) {
      return Simpplr.Salesforce.sendRequest({
          data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'tileId' : tileId},
          method:'POST',
          endpoint: Simpplr.Salesforce.Endpoints.ReadOnly +'?target=TileDataServer&action=getTile'
      });
	},
	
	setPositions :function (data, position) {
      return Simpplr.Salesforce.sendRequest({
          data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'position' : JSON.stringify(position)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=setPositions'
      });
	},
	
	setLayout :function (data, layout) {
      return Simpplr.Salesforce.sendRequest({
      	  data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'layout' : layout},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=setLayout'
      });
	},
	
	addTile :function (data, tile) {
      return Simpplr.Salesforce.sendRequest({
      	  data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'tile': JSON.stringify(tile)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=addTile'
      });
	},
	
	removeTile :function (data, tileId) {
	  return Simpplr.Salesforce.sendRequest({
      	  data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'tileId' : tileId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=removeTile'
      });
	},
	
	editTile :function (data, tileId, tile) {
      return Simpplr.Salesforce.sendRequest({
      	  data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId, 'tileId' : tileId, 'tile' : JSON.stringify(tile)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=editTile'
      });
	},
	
	resetToDefault :function (data) {
      return Simpplr.Salesforce.sendRequest({
          data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=resetToDefault'
      });
	},
	
	applyDefaultHomeToAllUsers :function (data) {
      return Simpplr.Salesforce.sendRequest({
    	  data: {'siteId' : data.siteId, 'dashboardId': data.dashboardId, 'segmentId': data.segmentId},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +'?target=TileDataServer&action=applyDefaultHomeToAllUsers'
      });
	},
	
}
