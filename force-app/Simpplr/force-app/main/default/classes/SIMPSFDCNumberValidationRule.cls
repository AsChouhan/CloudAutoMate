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
 * A class to verify number (double) values
 */
public with sharing class SIMPSFDCNumberValidationRule extends SIMPSFDCBaseValidationRule {
	
	private Double minValue = 0; // The minimum value allowed
	private Double maxValue = 0; // The maximum value allowed
	
	// Set maximum string length to be more than enough for any double value we can handle
	private Integer maxStrLength = 50;
	
	private static final Pattern DOUBLE_PATTERN = null;

	static {
		DOUBLE_PATTERN = Pattern.compile(SIMPSFDCPatterns.DoubleStr);
	}
	
	private SIMPSFDCStringValidationRule svrule = null; 
	
	private SIMPSFDCNumberValidationRule( String typeName) {
		// prevent use of this constructor - so that minValue and maxValue are guaranteed to be set 
		super(typeName);
	}

	public SIMPSFDCNumberValidationRule( String typeName, Double minValue, Double maxValue ) {
		super(typeName);
		
		if (minValue > maxValue)
			throw new SIMPSFDCValidator.SFDCValidationException('maxValue must be larger than minValue');
		
		this.minValue = minValue;
		this.maxValue = maxValue;
		
		// get default regex string validator for double
		svrule = readDefaultDoubleRule();
	}
	
	private SIMPSFDCStringValidationRule readDefaultDoubleRule() {
		SIMPSFDCStringValidationRule svr = new SIMPSFDCStringValidationRule( 'doublerule', DOUBLE_PATTERN.pattern() );
		svr.setMaximumLength(getMaxDoubleStrLength());
		svr.setAllowNull( false );
		return svr;
	}

    /**
     * This function will perform the following tests, and throw an exception if any of them fail.
     *   - is null or zero bytes and allow null was set to false
     *   - value is larger than maxValue
     *   - value is smaller than minValue
     *   - value is not a valid double number
     * If all tests passed it will return the input as Double 
     */
	public Double getValid(String input ) {
		return safelyParse(input);
	}
	
	private Double safelyParse(String input) {
	    if ( SIMPSFDCStringUtils.isEmpty(input) ) {
			if (isAllowNull()) {
				return null;
			}
			throw new SIMPSFDCValidator.SFDCValidationException('Input number required');
	    }
	    
	    // make sure string contains only valid double characters using regex
	    try {
	    	svrule.assertValid(input);
	    } catch (Exception e) {
	    	// String did not match the regex pattern or other basic string rule checks
	    	throw new SIMPSFDCValidator.SFDCValidationException('Invalid number input');
	    }
	    
		// RegEx is ok , so try to convert string to double
		Double d;
		try {
			d = Double.valueOf(input);
		} catch (Exception e) {
			throw new SIMPSFDCValidator.SFDCValidationException('Invalid number input');
		}
		
		// validate min and max
		if (d < minValue) {
			throw new SIMPSFDCValidator.SFDCValidationException('Invalid number input must be between ' + minValue + ' and ' + maxValue);
		}
		if (d > maxValue) {
			throw new SIMPSFDCValidator.SFDCValidationException('Invalid number input must be between ' + minValue + ' and ' + maxValue);
		}			
		return d;
	}
	
	/**
	 * @return the max double string length
	 */
	private Integer getMaxDoubleStrLength() {
		return maxStrLength;
	}
}