({
	addValue : function(component, event, helper) {
		console.log('child cons');
		var fld = component.get("v.field");
		var record = component.get("v.record");

		var val = record[fld];
		console.log(val+'  '+fld+'  '+record.SuppliedName);
		component.set("v.fldValue", val);
	}
})