/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class LocaleContext {
	
	private static Map<String, Map<String, String>> langLabelMap; 
	private static Set<String> loadedStaticResourceSet = new Set<String>();

    public static Map<String, String> getLabelMap(String targetName, String locale) {
     	if(langLabelMap == null){
	    	langLabelMap = getLangKeyValueMap(targetName, new List<String>{locale});
    	} else if(!loadedStaticResourceSet.contains(targetName + '_' + locale)){
			if(langLabelMap.containsKey(locale)) {
				langLabelMap.get(locale).putAll(getLangKeyValueMap(targetName, new List<String>{locale}).get(locale));
			} else {
				langLabelMap.putAll(getLangKeyValueMap(targetName, new List<String>{locale}));
			}
    		
    	}
		return langLabelMap.get(locale);
	}

	public static Map<String, Map<String, String>> getAllLabelMap(String targetName, List<String> localeList) {
     	if(langLabelMap == null){
	    	langLabelMap = getLangKeyValueMap(targetName, localeList);
    	} else {
			List<String> pendingLocaleList = new List<String>();
			for(String locale : localeList) {
				if(!loadedStaticResourceSet.contains(targetName + '_' + locale)) {
					pendingLocaleList.add(locale);
				}
			}
			if(!pendingLocaleList.isEmpty()) {
				Map<String, Map<String, String>> newLangLabelMap = getLangKeyValueMap(targetName,pendingLocaleList);
				for(String locale : newLangLabelMap.keySet()) {
					if(langLabelMap.containsKey(locale)) {
						langLabelMap.get(locale).putAll(newLangLabelMap.get(locale));
					} else {
						langLabelMap.put(locale, newLangLabelMap.get(locale));
					}
				}
			}
    	}
    	return langLabelMap;
    }

	/**
    	Returns corresponding localized strings for the keys
    **/
	private static Map<String, Map<String, String>> getLangKeyValueMap(String target, List<String> langCodeList){
    	if(String.isBlank(target)){
    		throw new SimpplrException('target cant be blank.');
    	}
    	
    	if(langCodeList == null || langCodeList.isEmpty()){
    		langCodeList = new List<String>{ServiceConstants.SUPPORTED_LOCALE_MAP.get('en_US')};
    	}
    	
    	List<String> staticResourceNameList = new List<String>();

		for (String langCodeName : langCodeList){
			staticResourceNameList.add(target + '_' + langCodeName);
		}
		loadedStaticResourceSet.addAll(staticResourceNameList);
    	
    	Map<String, Map<String, String>> messagePropMap = new Map<String, Map<String, String>>();
    	List<StaticResource> localizationResourceList = [SELECT Id, Body, Name FROM StaticResource WHERE Name IN :staticResourceNameList AND NamespacePrefix = :SimpplrContext.packageName WITH SECURITY_ENFORCED];
		for(StaticResource srObj : localizationResourceList){
			Map<String, String> tempMap = (Map<String, String>) JSON.deserialize(srObj.Body.toString(), Map<String, String>.class);
			messagePropMap.put(srObj.Name.right(5), tempMap);
		}
		
		return messagePropMap;
    }

	public static String getLabel(String languagelocalekey, String key) {
		if(langLabelMap == null || !langLabelMap.containsKey(languagelocalekey)) {
			throw new SimpplrException('Missing label map for ' + languagelocalekey);
		}
		String label = langLabelMap.get(languagelocalekey).get(key);
		if(String.isBlank(label)) {
			return languagelocalekey + '.' + key;
		}
		return label;
	}

	// DD MMMM (26 January)
	public static String getLocalisedDateAsDDMMMM(Datetime dtArg, String languagelocalekey){
		return dtArg.format('dd') + ' ' + getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM'));
	}

	// DD MMMM, YYYY (26 January, 1960)
	public static String getLocalisedDateAsDDMMMMYYYY(Datetime dtArg, String languagelocalekey){
		return dtArg.format('dd') + ' ' + getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM')) + ' ' + dtArg.format('yyyy');
	}

	// DD MMMM, YYYY (26 January, 1960)
	public static String getLocalisedDateAsDDMMYYYY(Datetime dtArg, String languagelocalekey){
		return dtArg.format('dd') + ' ' + getLabel(languagelocalekey, 'common.date.month.short.' + dtArg.format('MM')) + ' ' + dtArg.format('yyyy');
	}

	// DD MMMM YYYY hh:mm:ss (26 January 1960 01:01:01)
	public static String getLocalisedDateAsDDMMMMYYYYhhmmss(Datetime dtArg, String languagelocalekey){
		return dtArg.format('dd') + ' ' + getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM')) + ' ' + dtArg.format('yyyy') + ' ' + dtArg.format('HH:mm:ss');
	}

	// MMMM DD, YYYY (January 26, 1960)
	public static String getLocalisedDateAsMMMMDDYYYY(Datetime dtArg, String languagelocalekey){
		return getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM')) + ' ' + dtArg.format('dd, yyyy');
	}

	// MMM DD, YYYY (Jan 26, 1960)
	public static String getLocalisedDateAsMMMDDYYYY(Datetime dtArg, String languagelocalekey,String timeZonesidkey){

		return getLabel(languagelocalekey, 'common.date.month.short.' + dtArg.format('MM',timeZonesidkey)) + ' ' + dtArg.format('dd, yyyy',timeZonesidkey);
	}

	public static String getLocalisedDateAsMMMDDYYYYhhmmss(Datetime dtArg, String languagelocalekey){

		return getLabel(languagelocalekey, 'date.month.short.' + dtArg.format('MM')) + ' ' + dtArg.format('dd, yyyy') + 
				' ' + 
				dtArg.format('h:mm') + getLabel(languagelocalekey, 'common.date_' + dtArg.format('a').toLowercase());
	}

	// HH:mmaa (6:57pm)
	public static String getLocalisedDateAs12HourFormatTime(Datetime dtArg, String languagelocalekey,String timeZonesidkey){

		return dtArg.format('h:mm',timeZonesidkey) + getLabel(languagelocalekey, 'common.date_' + dtArg.format('a',timeZonesidkey).toLowercase());
	}

	// MMMM DD, YYYY (January 26, 1960) in given timezone
	public static String getLocalisedDateAsMMMMDDYYYY(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM',timeZonesidkey)) + ' ' + dtArg.format('dd, yyyy',timeZonesidkey);
	}

	// MMMM YYYY (January 1960)
	public static String getLocalisedDateAsMMMMYYYY(Datetime dtArg, String languagelocalekey){
		return getLabel(languagelocalekey, 'common.date.month.' + dtArg.format('MM')) + ' ' + dtArg.format('yyyy');
	}

	// Day of the date (Fri Jan 1, 2019)
	public static String getLocalisedDayAndDate(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'email.day.short.0' + dtArg.format('u',timeZonesidkey)) + ', ' + 
				getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ' ' + 
				dtArg.format('dd, yyyy',timeZonesidkey);
	}

	// 'EEEE d MMM, YYYY' - (Friday 1 JAN, 1960)
	public static String getLocalisedDateAsEEEEDMMMYYYY(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'email.day.0' + dtArg.format('u',timeZonesidkey)) + ' ' + 
				dtArg.format('dd',timeZonesidkey) + ' ' + 
				getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ', ' +
				dtArg.format('yyyy',timeZonesidkey);
	}

	// 'EEEE MMM d, YYYY' - (Friday JAN 1, 1960)
	public static String getLocalisedDateAsEEEEMMMDYYYY(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'email.day.0' + dtArg.format('u',timeZonesidkey)) + ' ' + 
				getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ' ' + 
				dtArg.format('dd',timeZonesidkey) + ', ' +
				dtArg.format('yyyy',timeZonesidkey);
	}

	// DD MMMM, YYYY (26 January, 1960)
	// dateStr: 2016-04-24 i.e. YYYY-mm-dd
	public static String getLocalisedDateCSV(String dateStr, String languagelocalekey){ 
		List<String> parts = dateStr.split('-');

		return parts[2] + ' ' + getLabel(languagelocalekey, 'common.date.month.' + parts[1]) + ' ' + parts[0];
	}

	// dateStr: Mon, Nov 11 at 3:30 pm
	public static String getLocalisedDateAsUMMDDHHMMAA(Datetime dtArg, String languagelocalekey,String timeZonesidkey){

		String dateComponent = getLabel(languagelocalekey, 'email.day.short.0' + dtArg.format('u',timeZonesidkey)) + ', ' + 
								getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ' ' + 
								dtArg.format('dd',timeZonesidkey);
		String timeComponent = getLocalisedDateAs12HourFormatTime(dtArg, languagelocalekey, timeZonesidkey);					

		String finalLocalizedDate = dateComponent + ' ' + getLabel(languagelocalekey,'email.common.at_time') + ' ' + timeComponent;

		return finalLocalizedDate;
				
	}

	// dateStr: Mon, Nov 11, 2021 at 3:30 pm
	public static String getLocalisedDateAsUMMDDYYYYHHMMAA(Datetime dtArg, String languagelocalekey,String timeZonesidkey){

		String dateComponent = getLabel(languagelocalekey, 'email.day.short.0' + dtArg.format('u',timeZonesidkey)) + ', ' + 
								getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ' ' + 
								dtArg.format('dd',timeZonesidkey)+ ', ' +
								dtArg.format('yyyy',timeZonesidkey);
		String timeComponent = getLocalisedDateAs12HourFormatTime(dtArg, languagelocalekey, timeZonesidkey);					

		String finalLocalizedDate = dateComponent + ' ' + getLabel(languagelocalekey,'email.common.at_time') + ' ' + timeComponent;

		return finalLocalizedDate;
				
	}

	public static String getLocalisedDateWithTime(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'common.date.month.short.'+dtArg.format('MM',timeZonesidkey)) + ' ' + 
				dtArg.format('dd, yyyy',timeZonesidkey)+' '+
				getLabel(languagelocalekey,'email.common.at_time')+' '+
				dtArg.format('h:mm',timeZonesidkey)+
				getLabel(languagelocalekey,'common.date_'+dtArg.format('a',timeZonesidkey).toLowercase());

	}

	public static String getLocalisedMonth(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'common.date.month.short.' + dtArg.format('MM',timeZonesidkey));
	}

	public static String getLocalisedDayOfWeek(Datetime dtArg, String languagelocalekey,String timeZonesidkey){
		return getLabel(languagelocalekey, 'email.day.' + dtArg.format('uu',timeZonesidkey));
	}

	public static String getLocalisedContentTypeLabel(String languagelocalekey, String contentType) {
		String  localisedContentTypeLabel = '';
		Map<String, String> keyMap = new Map<String, String>{
			'album' => 'common.content_type.album',
			'blog'	=> 'common.content_type.blog_post',
			'event'	=> 'common.content_type.event',
			'page'	=> 'common.content_type.page',
			'blogpost'	=> 'common.content_type.blog_post'
		};
		if(String.isNotBlank(contentType)) {
			localisedContentTypeLabel = getLabel(languagelocalekey, keyMap.get(contentType.toLowerCase()));
		}
		return localisedContentTypeLabel;
	}
    
}