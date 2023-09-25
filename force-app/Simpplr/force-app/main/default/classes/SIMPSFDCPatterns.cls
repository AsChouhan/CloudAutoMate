/**
 * OWASP Enterprise Security API (ESAPI)
 * 
 * This file is part of the Open Web Application Security Project (OWASP)
 * Enterprise Security API (ESAPI) project. For details, please see
 * <a href="http://www.owasp.org/index.php/ESAPI">http://www.owasp.org/index.php/ESAPI</a>.
 *
 * Copyright (c) 2010 - Salesforce.com
 * 
 * The Apex ESAPI implementation is published by Salesforce.com under the New BSD license. You should read and accept the
 * LICENSE before you use, modify, and/or redistribute this software.
 * 
 * @author Yoel Gluck (securecloud .at. salesforce.com) <a href="http://www.salesforce.com">Salesforce.com</a>
 * @created 2010
 */

/**
 * This class contains default RegEx patterns used in this library.
 */
public with sharing class SIMPSFDCPatterns {

	/**
	 * dd/MM/yy
	 */
	public static final String Date1 = '^([123]0|[012][1-9]|31)/(0[1-9]|1[012])/(\\d{2})$';
	
	/**
	 * dd/MM/yyyy
	 */
	public static final String Date2 = '^([123]0|[012][1-9]|31)/(0[1-9]|1[012])/(19[0-9]{2}|2[0-9]{3})$';
	
	/**
	 * dd/MM/(yy)yy
	 */
	public static final String Date3 = '^([123]0|[012][1-9]|31)/(0[1-9]|1[012])/(19[0-9]{2}|2[0-9]{3}|\\d{2})$';
	
	/**
	 * (d)d/-.(M)M/-.(yy)yy
	 */
	public static final String Date4 = '^([123]0|[012]?[1-9]|31)[\\/\\.\\-](0?[1-9]|1[012])[\\/\\.\\-](19[0-9]{2}|2[0-9]{3}|\\d{2})$';
	
	/**
	 * MM/dd/yy
	 */
	public static final String Date5 = '^(0[1-9]|1[012])/([123]0|[012][1-9]|31)/(\\d{2})$';
	
	/**
	 * MM/dd/yyyy
	 */
	public static final String Date6 = '^(0[1-9]|1[012])/([123]0|[012][1-9]|31)/(19[0-9]{2}|2[0-9]{3})$';
	
	/**
	 * MM/dd/(yy)yy
	 */
	public static final String Date7 = '^(0[1-9]|1[012])/([123]0|[012][1-9]|31)/(19[0-9]{2}|2[0-9]{3}|\\d{2})$';
	
	/**
	 * (M)M/-.(d)d/-.(yy)yy
	 */
	public static final String Date8 = '^(0?[1-9]|1[012])[\\/\\.\\-]([123]0|[012]?[1-9]|31)[\\/\\.\\-](19[0-9]{2}|2[0-9]{3}|\\d{2})$';
	
	/**
	 * yyyy/MM/dd
	 */
	public static final String Date9 = '^(19[0-9]{2}|2[0-9]{3})/(0[1-9]|1[012])/([123]0|[012][1-9]|31)$';
	
	/**
	 * (yy)yy/-.(M)M/-.(d)d
	 */
	public static final String Date10 = '^(19[0-9]{2}|2[0-9]{3}|\\d{2})[\\/\\.\\-](0?[1-9]|1[012])[\\/\\.\\-]([123]0|[012]?[1-9]|31)$';
	
	
	/**
	 * hh:mm AM/PM
	 */
	public static final String Time1 = '^(0[1-9]|1[012]):([0-5]\\d) [APap][mM]$';
	
	/**
	 * (h)h:mm AM/PM
	 */
	public static final String Time2 = '^(0?[1-9]|1[012]):([0-5]\\d) [APap][mM]$';
	
	/**
	 * hh:mm:ss AM/PM
	 */
	public static final String Time3 = '^(0?[1-9]|1[012])(:[0-5]\\d){2} [APap][mM]$';
	
	/**
	 * hh:mm 24
	 */
	public static final String Time4 = '^([0-1]\\d|2[0-3]):([0-5]\\d)$';
	
	/**
	 * (h)h:mm 24
	 */
	public static final String Time5 = '^([0-1]?\\d|2[0-3]):([0-5]\\d)$';
	
	/**
	 * hh:mm:ss 24
	 */
	public static final String Time6 = '^([0-1]\\d|2[0-3])(:[0-5]\\d){2}$';
	
	/**
	 * yyyy(-/)MM(-/)dd(T )hh(:)mm(:)ss(Z)( +-)(hh:mm)
	 */
	public static final String DateTime1 = '^((\\d{4})[/-]?(0[1-9]|1[012])[/-]?([123]0|[012][1-9]|31))([T ])(([0-1]\\d|2[0-3])(:?[0-5]\\d){2})(Z|( ([+-]([0-1]\\d|2[0-3])(:?[0-5]\\d)?)))$';

	/**
	 * File name. Allowed characters are alpha numeric and: ()+. '&,-=_
	 */
	public static final String FileName = '^[\\(\\)\\+\\. \'&,-=_\\da-zA-Z]{1,255}$';

	/**
	 * Domain. Allowed characters are alpha numeric and dash. Domain can have between two and 127 levels. 
	 * Each level can contain between one and 63 characters. 
	 */
	public static final String Domain = '^([a-zA-Z0-9-]{1,63})((\\.([a-zA-Z0-9-]{1,63})){1,127})$';

	/**
	 * URL. Allowed characters are alpha numeric and: .&+/=?#\. Percentage can only be used preceding two valid HEX characters. 
	 */
	public static final String URL = '^([a-zA-Z0-9\\.\\&\\+\\/\\=\\?\\#\\\\]|%([0-9A-Fa-f]{2}))*$';

	/**
	 * Credit card. Allowed characters are numeric spaces and dashes. The format must be four groups of four digits each. 
	 * They may have space or dash between the groups.  
	 */
	public static final String CreditCard = '^(\\d{4}[- ]?){3}\\d{4}$';

	/**
	 * Double. Any valid double string including with exponent.  
	 */
	public static final String DoubleStr = '^([+-]?\\d+\\.\\d+[eE][+-]?\\d{1,3})|([+-]?\\.\\d+[eE][+-]?\\d{1,3})|([+-]?\\d+\\.?[eE][+-]?\\d{1,3})|([+-]?\\d+\\.\\d+)|([+-]?\\.\\d+)|([+-]?\\d+\\.?)$';

	/**
	 * Integer. Any valid integer string.  
	 */
	public static final String IntegerStr = '^([+-]?\\d+)$';
	
	// this inner class is used for connecting a pattern name to a pattern string
	// I use it for testing only
	/*
	public with sharing class SFDCPattern {
		public String name;
		public String value;
		
		public SFDCPattern(String name, String value) {
			this.name = name;
			this.value = value;
		}
	}
	*/

	// The following adds all date patterns to the allDatePatterns array.
	// I am disabling this so it does not burn governor limits when not in testing mode. Enable if needed.
	/*	
	public static final SFDCPattern [] allDatePatterns;
	
	static {
		allDatePatterns = new SFDCPattern[]{};
		
		allDatePatterns.add(new SFDCPattern('dd/MM/yy', Date1));
		allDatePatterns.add(new SFDCPattern('dd/MM/yyyy', Date2));
		allDatePatterns.add(new SFDCPattern('dd/MM/(yy)yy', Date3));
		allDatePatterns.add(new SFDCPattern('(d)d/-.(M)M/-.(yy)yy', Date4));
		allDatePatterns.add(new SFDCPattern('MM/dd/yy', Date5));
		allDatePatterns.add(new SFDCPattern('MM/dd/yyyy', Date6));
		allDatePatterns.add(new SFDCPattern('MM/dd/(yy)yy', Date7));
		allDatePatterns.add(new SFDCPattern('(M)M/-.(d)d/-.(yy)yy', Date8));
		allDatePatterns.add(new SFDCPattern('yyyy/MM/dd', Date9));
		allDatePatterns.add(new SFDCPattern('(yy)yy/-.(M)M/-.(d)d', Date10));
		
		allDatePatterns.add(new SFDCPattern('hh:mm AM/PM', Time1));
		allDatePatterns.add(new SFDCPattern('(h)h:mm AM/PM', Time2));
		allDatePatterns.add(new SFDCPattern('hh:mm:ss AM/PM', Time3));
		allDatePatterns.add(new SFDCPattern('hh:mm 24', Time4));
		allDatePatterns.add(new SFDCPattern('(h)h:mm 24', Time5));
		allDatePatterns.add(new SFDCPattern('hh:mm:ss 24', Time6));
		
		allDatePatterns.add(new SFDCPattern('yyyy(-/)MM(-/)dd(T )hh(:)mm(:)ss(Z)( +-)(hh:mm)', DateTime1));
	}
	*/
}