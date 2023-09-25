Simpplr.Salesforce.Launchpad = {

  search :function (data) {
  	  Simpplr.Salesforce.log('Launchpad.search---data---'+ JSON.stringify(data));
      return Simpplr.Salesforce.sendRequest({
          data: {'data' : JSON.stringify(data)},
          method:'POST',
          endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +'?target=LaunchpadDataServer&action=search'
      });
  }
}