({
    getRecs : function(component, event) {	//Get picklist values, objects and count of Records
        var getCards = component.get("c.getRelRec");
        for(var x of component.get("v.selectedFields")){
            console.log(x);
        }
        getCards.setParams({ "objectname" : component.get("v.selectedObject"), "picklistNamestr" : component.get('v.selectedField'), "fields": component.get("v.selectedFields")});
        getCards.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var arrayMapKeys = [];
                var sortedArray = [];
                var result = response.getReturnValue();
                // Adding count values [it include only that fields which has releted sobject ]...
                for(var key in result){
                    arrayMapKeys.push({key:key, value:result[key], count:result[key].length});
                }
                var PL = component.get('v.picklistVal');    
                // If any pickList value does not have releted sobject then count set to Zero(0)...       
                for(var st = 0; st < PL.length; st++) {
                    var flag = 0;
                    for(var stAg = 0; stAg < arrayMapKeys.length; stAg++) {
                        if(arrayMapKeys[stAg].key == PL[st]) {
                            flag = 1;
                            break;
                        }
                    }
                    if(flag == 0) {
                        arrayMapKeys.push({key:PL[st], value:[], count:0});
                    }
                }
                // sortedArray includes all pickListfueld value .....
                for(var check = 0 ; check < PL.length; check++) {
                    for(var strt = 0; strt < arrayMapKeys.length; strt++) {
                        if(PL[check] == arrayMapKeys[strt].key) {
                            sortedArray.push({key:arrayMapKeys[strt].key, value:arrayMapKeys[strt].value, count:arrayMapKeys[strt].count});
                        }
                    }
                }
                component.set('v.relRecs', sortedArray);
                component.set('v.done', true);
            }
            component.set("v.spinner", false);
        });           
        $A.enqueueAction(getCards);
    }
})