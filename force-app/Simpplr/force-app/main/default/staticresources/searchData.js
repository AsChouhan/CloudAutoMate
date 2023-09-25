Simpplr.Salesforce.SearchData = {
    requsetObj : {
        method : 'GET',
        endpoint : '',
        data : ''
    },
    
    sendRequest  : function(request){ 
        return $.ajax({
            type: requset.method,
            url: requset.endpoint,
            data : requset.data,
            beforeSend: function(xhrObj){
                xhrObj.setRequestHeader("Content-Type","application/json");
                xhrObj.setRequestHeader("Accept","application/json");
            }
        });
      
    }
    
} ;