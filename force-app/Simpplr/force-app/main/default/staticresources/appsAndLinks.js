Simpplr = Simpplr || {};
Simpplr.Salesforce = Simpplr.Salesforce || {};
Simpplr.Salesforce.AppsAndLinks = {
    get(segmentId) {
        Simpplr.Salesforce.log("AppsAndLinks.get---segmentId---"+ segmentId);
        return Simpplr.Salesforce.sendRequest({
            data: {"segmentId" : segmentId},
            method:"POST",
            endpoint:Simpplr.Salesforce.Endpoints.ReadOnly +"?target=AppsAndLinksDataServer&action=get"
        });
    },
    save(data, segmentId) {
        Simpplr.Salesforce.log("AppsAndLinks.save---segmentId---"+ segmentId + "---data---"+data);
        return Simpplr.Salesforce.sendRequest({
            data: {"segmentId" : segmentId, "data": JSON.stringify(data)},
            method:"POST",
            endpoint:Simpplr.Salesforce.Endpoints.ReadWrite +"?target=AppsAndLinksDataServer&action=save"
        });
    }
};